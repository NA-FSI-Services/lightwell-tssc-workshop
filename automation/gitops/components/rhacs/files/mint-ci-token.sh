#!/usr/bin/env bash
# Mint Central CI token, copy rhacs-ci-secrets into the learner build namespace
# (Tekton mounts secrets from the TaskRun ns), and register the internal
# OpenShift registry so roxctl image check can enrich lw-poc-build images.
set -euo pipefail

if ! command -v oc >/dev/null 2>&1; then
  curl -fsSL -o /tmp/oc.tgz \
    https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable/openshift-client-linux.tar.gz
  tar -C /usr/local/bin -xzf /tmp/oc.tgz oc
fi
if ! command -v python3 >/dev/null 2>&1; then
  dnf install -y -q python3 && dnf clean all
fi

echo "Waiting for Central Route + central-htpasswd (up to ${WAIT_SECONDS}s)..."
deadline=$((SECONDS + WAIT_SECONDS))
CENTRAL_HOST=""
while (( SECONDS < deadline )); do
  CENTRAL_HOST="$(oc -n "${NAMESPACE}" get route central -o jsonpath='{.spec.host}' 2>/dev/null || true)"
  if [[ -n "${CENTRAL_HOST}" ]] && oc -n "${NAMESPACE}" get secret central-htpasswd >/dev/null 2>&1; then
    break
  fi
  sleep 10
done
if [[ -z "${CENTRAL_HOST}" ]]; then
  echo "Central Route not ready" >&2
  exit 1
fi
if ! oc -n "${NAMESPACE}" get secret central-htpasswd >/dev/null 2>&1; then
  echo "central-htpasswd missing" >&2
  exit 1
fi

ENDPOINT="${CENTRAL_HOST}:443"
if [[ -z "${ENDPOINT}" || "${ENDPOINT}" == ":443" ]]; then
  ENDPOINT="${FALLBACK_ENDPOINT}"
fi

existing="$(oc -n "${NAMESPACE}" get secret "${SECRET_NAME}" -o jsonpath='{.data.rox-api-token}' 2>/dev/null || true)"
if [[ -n "${existing}" ]]; then
  echo "Secret ${NAMESPACE}/${SECRET_NAME} already has rox-api-token — skip mint"
  oc -n "${NAMESPACE}" patch secret "${SECRET_NAME}" --type merge \
    -p "{\"stringData\":{\"rox-api-endpoint\":\"${ENDPOINT}\"}}" >/dev/null || true
else
  ADMIN_PASS="$(oc -n "${NAMESPACE}" get secret central-htpasswd -o jsonpath='{.data.password}' | base64 -d)"
  echo "Minting API token role='${TOKEN_ROLE}' name='${TOKEN_NAME}' against ${CENTRAL_HOST}..."
  RESP="$(curl -sk -u "admin:${ADMIN_PASS}" \
    "https://${CENTRAL_HOST}/v1/apitokens/generate" \
    -H 'Content-Type: application/json' \
    -d "{\"name\":\"${TOKEN_NAME}\",\"roles\":[\"${TOKEN_ROLE}\"]}")"
  TOKEN="$(printf '%s' "${RESP}" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("token") or "")')"
  if [[ -z "${TOKEN}" ]]; then
    echo "token mint failed: ${RESP}" >&2
    exit 1
  fi
  if oc -n "${NAMESPACE}" get secret "${SECRET_NAME}" >/dev/null 2>&1; then
    oc -n "${NAMESPACE}" patch secret "${SECRET_NAME}" --type merge \
      -p "{\"stringData\":{\"rox-api-endpoint\":\"${ENDPOINT}\",\"rox-api-token\":\"${TOKEN}\"}}"
  else
    oc -n "${NAMESPACE}" create secret generic "${SECRET_NAME}" \
      --from-literal=rox-api-endpoint="${ENDPOINT}" \
      --from-literal=rox-api-token="${TOKEN}"
  fi
  echo "Patched Secret ${NAMESPACE}/${SECRET_NAME} (endpoint + token)."
fi

# Tekton cluster-resolves the Task from stackrox but mounts secrets in the TaskRun ns.
if [[ -n "${BUILD_NAMESPACE:-}" ]]; then
  EP="$(oc -n "${NAMESPACE}" get secret "${SECRET_NAME}" -o jsonpath='{.data.rox-api-endpoint}' | base64 -d)"
  TK="$(oc -n "${NAMESPACE}" get secret "${SECRET_NAME}" -o jsonpath='{.data.rox-api-token}' | base64 -d)"
  if [[ -n "${TK}" ]]; then
    oc -n "${BUILD_NAMESPACE}" create secret generic "${SECRET_NAME}" \
      --from-literal=rox-api-endpoint="${EP}" \
      --from-literal=rox-api-token="${TK}" \
      --dry-run=client -o yaml | oc apply -f -
    echo "Copied Secret ${BUILD_NAMESPACE}/${SECRET_NAME} for acs-image-check TaskRuns."
  fi
fi

if [[ "${REGISTRY_INTEGRATION:-true}" != "true" ]]; then
  exit 0
fi

ADMIN_PASS="$(oc -n "${NAMESPACE}" get secret central-htpasswd -o jsonpath='{.data.password}' | base64 -d)"
PULL_TOKEN="$(oc create token "${PULLER_SA}" -n "${NAMESPACE}" --duration=8760h)"
export CENTRAL_HOST ADMIN_PASS PULL_TOKEN REGISTRY_ENDPOINT INTEGRATION_NAME
python3 - <<'PY'
import json, os, ssl, sys, urllib.error, urllib.request, base64

host = os.environ["CENTRAL_HOST"]
admin = os.environ["ADMIN_PASS"]
token = os.environ["PULL_TOKEN"]
endpoint = os.environ["REGISTRY_ENDPOINT"]
name = os.environ["INTEGRATION_NAME"]
ctx = ssl._create_unverified_context()
basic = base64.b64encode(f"admin:{admin}".encode()).decode()

def req(method, path, body=None):
    data = None if body is None else json.dumps(body).encode()
    r = urllib.request.Request(
        f"https://{host}{path}",
        data=data,
        method=method,
        headers={
            "Content-Type": "application/json",
            "Authorization": f"Basic {basic}",
        },
    )
    try:
        with urllib.request.urlopen(r, context=ctx, timeout=60) as resp:
            return json.loads(resp.read().decode() or "{}")
    except urllib.error.HTTPError as exc:
        detail = exc.read().decode() if exc.fp else ""
        print(f"{method} {path} failed: {exc.code} {detail}", file=sys.stderr)
        raise SystemExit(1) from exc

payload = {
    "name": name,
    "type": "docker",
    "categories": ["REGISTRY"],
    "skipTestIntegration": True,
    "docker": {
        "endpoint": endpoint,
        "username": "serviceaccount",
        "password": token,
        "insecure": True,
    },
}
listing = req("GET", "/v1/imageintegrations")
items = listing.get("integrations") or listing.get("imageIntegrations") or []
existing = None
for item in items:
    docker = item.get("docker") or {}
    if item.get("name") == name or docker.get("endpoint") == endpoint:
        existing = item
        break
if existing:
    existing["docker"] = existing.get("docker") or {}
    existing["docker"].update(payload["docker"])
    existing["skipTestIntegration"] = True
    existing["categories"] = payload["categories"]
    req("PUT", f"/v1/imageintegrations/{existing['id']}", existing)
    print(f"Updated image integration {name} ({endpoint})")
else:
    req("POST", "/v1/imageintegrations", payload)
    print(f"Created image integration {name} ({endpoint})")
PY
