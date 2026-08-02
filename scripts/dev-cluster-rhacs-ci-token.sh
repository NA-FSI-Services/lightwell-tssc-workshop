#!/usr/bin/env bash
# Mint an RHACS Central API token (Continuous Integration role) and patch
# Secret rhacs-ci-secrets for Tekton Task acs-image-check (Module 5).
#
# Dev-cluster / claim QA only. Never commit the token.
# Requires: oc login as cluster-admin, Central Ready, curl, jq.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT}"

NS="${RHACS_NAMESPACE:-stackrox}"
SECRET_NAME="${RHACS_CI_SECRET_NAME:-rhacs-ci-secrets}"
TOKEN_NAME="${RHACS_CI_TOKEN_NAME:-lightwell-ci}"
ROLE="${RHACS_CI_ROLE:-Continuous Integration}"
WAIT_SECONDS="${WAIT_CENTRAL_SECONDS:-180}"

if ! command -v oc >/dev/null 2>&1; then
  echo "dev-cluster-rhacs-ci-token: oc not found on PATH" >&2
  exit 1
fi
if ! command -v jq >/dev/null 2>&1; then
  echo "dev-cluster-rhacs-ci-token: jq required" >&2
  exit 1
fi
if ! oc whoami >/dev/null 2>&1; then
  echo "dev-cluster-rhacs-ci-token: not logged in — run ./scripts/dev-cluster-login.sh first" >&2
  exit 1
fi

echo "Waiting for Central Route in ${NS}..."
deadline=$((SECONDS + WAIT_SECONDS))
CENTRAL_HOST=""
while (( SECONDS < deadline )); do
  CENTRAL_HOST="$(oc -n "${NS}" get route central -o jsonpath='{.spec.host}' 2>/dev/null || true)"
  if [[ -n "${CENTRAL_HOST}" ]]; then
    break
  fi
  sleep 5
done
if [[ -z "${CENTRAL_HOST}" ]]; then
  echo "dev-cluster-rhacs-ci-token: Central Route not found in ${NS}" >&2
  exit 1
fi

if ! oc -n "${NS}" get secret central-htpasswd >/dev/null 2>&1; then
  echo "dev-cluster-rhacs-ci-token: secret central-htpasswd missing (is Central Ready?)" >&2
  exit 1
fi

ADMIN_PASS="$(oc -n "${NS}" get secret central-htpasswd -o jsonpath='{.data.password}' | base64 -d)"
ENDPOINT="${CENTRAL_HOST}:443"

echo "Minting API token role='${ROLE}' name='${TOKEN_NAME}' against ${ENDPOINT}..."
RESP="$(curl -sk -u "admin:${ADMIN_PASS}" \
  "https://${CENTRAL_HOST}/v1/apitokens/generate" \
  -H 'Content-Type: application/json' \
  -d "{\"name\":\"${TOKEN_NAME}\",\"roles\":[\"${ROLE}\"]}")"

TOKEN="$(echo "${RESP}" | jq -r '.token // empty')"
if [[ -z "${TOKEN}" || "${TOKEN}" == "null" ]]; then
  echo "dev-cluster-rhacs-ci-token: token mint failed:" >&2
  echo "${RESP}" | jq . >&2 || echo "${RESP}" >&2
  exit 1
fi

# Endpoint comes from Helm; only patch the token so Argo cannot wipe it if
# charts/components/rhacs/templates/ci-secret-placeholder.yaml omits rox-api-token.
if oc -n "${NS}" get secret "${SECRET_NAME}" >/dev/null 2>&1; then
  oc -n "${NS}" patch secret "${SECRET_NAME}" --type merge \
    -p "{\"stringData\":{\"rox-api-endpoint\":\"${ENDPOINT}\",\"rox-api-token\":\"${TOKEN}\"}}"
else
  oc -n "${NS}" create secret generic "${SECRET_NAME}" \
    --from-literal=rox-api-endpoint="${ENDPOINT}" \
    --from-literal=rox-api-token="${TOKEN}"
fi

echo "Patched Secret ${NS}/${SECRET_NAME} (rox-api-endpoint + rox-api-token)."
echo "Re-run Pipeline lightwell-build-policy-gate — acs-image-check should no longer skip."
