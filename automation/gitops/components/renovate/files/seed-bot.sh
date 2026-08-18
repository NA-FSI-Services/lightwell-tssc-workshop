#!/usr/bin/env bash
# Mint a Gitea token for renovate-bot and write it to a Secret.
# Never commit the token. Workshop bot password is a chart placeholder.
set -euo pipefail

: "${GITEA_ENDPOINT:?}"
: "${GITEA_NAMESPACE:?}"
: "${ADMIN_SECRET_NAME:?}"
: "${RENOVATE_NAMESPACE:?}"
: "${TOKEN_SECRET_NAME:?}"
: "${BOT_USER:?}"
: "${BOT_PASSWORD:?}"
: "${BOT_EMAIL:?}"
: "${BOT_FULL_NAME:?}"
: "${TOKEN_NAME:?}"
: "${TARGET_ORG:?}"
: "${TARGET_REPO:?}"
WAIT_SECONDS="${WAIT_SECONDS:-300}"

K8S_API="https://${KUBERNETES_SERVICE_HOST}:${KUBERNETES_SERVICE_PORT}"
SA_TOKEN="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)"
SA_CA="/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"

k8s_curl() {
  curl -sS --cacert "${SA_CA}" \
    -H "Authorization: Bearer ${SA_TOKEN}" \
    "$@"
}

echo "Waiting for Gitea at ${GITEA_ENDPOINT} ..."
deadline=$((SECONDS + WAIT_SECONDS))
until curl -fsS "${GITEA_ENDPOINT%/}/api/healthz" >/dev/null 2>&1; do
  if (( SECONDS >= deadline )); then
    echo "ERROR: Gitea did not become healthy in ${WAIT_SECONDS}s" >&2
    exit 1
  fi
  sleep 5
done
echo "Gitea is healthy."

admin_json="$(k8s_curl "${K8S_API}/api/v1/namespaces/${GITEA_NAMESPACE}/secrets/${ADMIN_SECRET_NAME}")"
ADMIN_USER="$(printf '%s' "${admin_json}" | python3 -c 'import json,base64,sys; s=json.load(sys.stdin); print(base64.b64decode(s["data"]["username"]).decode())')"
ADMIN_PASSWORD="$(printf '%s' "${admin_json}" | python3 -c 'import json,base64,sys; s=json.load(sys.stdin); print(base64.b64decode(s["data"]["password"]).decode())')"

API="${GITEA_ENDPOINT%/}/api/v1"

auth_header() {
  printf 'Authorization: Basic %s' "$(printf '%s:%s' "$1" "$2" | base64 -w0 2>/dev/null || printf '%s:%s' "$1" "$2" | base64)"
}

admin_auth() {
  auth_header "${ADMIN_USER}" "${ADMIN_PASSWORD}"
}

bot_auth() {
  auth_header "${BOT_USER}" "${BOT_PASSWORD}"
}

ensure_user() {
  local code
  code="$(curl -sS -o /tmp/gitea-bot-user.json -w '%{http_code}' \
    -H "$(admin_auth)" \
    "${API}/admin/users/${BOT_USER}" || true)"
  if [[ "${code}" == "200" ]]; then
    echo "User ${BOT_USER} already exists"
    return 0
  fi
  local payload
  payload="$(python3 - <<PY
import json, os
print(json.dumps({
  "username": os.environ["BOT_USER"],
  "password": os.environ["BOT_PASSWORD"],
  "email": os.environ["BOT_EMAIL"],
  "full_name": os.environ["BOT_FULL_NAME"],
  "must_change_password": False,
  "send_notify": False,
}))
PY
)"
  code="$(curl -sS -o /tmp/gitea-bot-create.json -w '%{http_code}' \
    -X POST \
    -H "$(admin_auth)" \
    -H 'Content-Type: application/json' \
    -d "${payload}" \
    "${API}/admin/users")"
  if [[ "${code}" == "201" ]]; then
    echo "Created user ${BOT_USER}"
    return 0
  fi
  if [[ "${code}" == "422" ]] && grep -qiE 'already exists|user already exists' /tmp/gitea-bot-create.json 2>/dev/null; then
    echo "User ${BOT_USER} already exists — continuing"
    return 0
  fi
  echo "ERROR: create user ${BOT_USER} failed HTTP ${code}" >&2
  cat /tmp/gitea-bot-create.json >&2 || true
  exit 1
}

delete_named_token() {
  local list_code
  list_code="$(curl -sS -o /tmp/gitea-bot-tokens.json -w '%{http_code}' \
    -H "$(bot_auth)" \
    "${API}/users/${BOT_USER}/tokens" || true)"
  if [[ "${list_code}" != "200" ]]; then
    return 0
  fi
  python3 - <<PY
import json
tokens = json.load(open("/tmp/gitea-bot-tokens.json"))
ids = [str(t["id"]) for t in tokens if t.get("name") == "${TOKEN_NAME}"]
open("/tmp/gitea-bot-token-ids", "w").write("\n".join(ids))
PY
  while IFS= read -r id; do
    [[ -z "${id}" ]] && continue
    curl -sS -o /dev/null -X DELETE \
      -H "$(bot_auth)" \
      "${API}/users/${BOT_USER}/tokens/${id}" || true
    echo "Deleted existing token ${TOKEN_NAME} id ${id}"
  done < /tmp/gitea-bot-token-ids
}

mint_token() {
  local payload code
  payload="$(python3 - <<PY
import json
print(json.dumps({
  "name": "${TOKEN_NAME}",
  "scopes": ["write:repository", "write:issue", "read:user", "write:notification"],
}))
PY
)"
  code="$(curl -sS -o /tmp/gitea-bot-token.json -w '%{http_code}' \
    -X POST \
    -H "$(bot_auth)" \
    -H 'Content-Type: application/json' \
    -d "${payload}" \
    "${API}/users/${BOT_USER}/tokens")"
  if [[ "${code}" != "201" ]]; then
    echo "WARN: scoped token create HTTP ${code}; retrying with scope all" >&2
    cat /tmp/gitea-bot-token.json >&2 || true
    payload="$(python3 - <<PY
import json
print(json.dumps({"name": "${TOKEN_NAME}", "scopes": ["all"]}))
PY
)"
    code="$(curl -sS -o /tmp/gitea-bot-token.json -w '%{http_code}' \
      -X POST \
      -H "$(bot_auth)" \
      -H 'Content-Type: application/json' \
      -d "${payload}" \
      "${API}/users/${BOT_USER}/tokens")"
  fi
  if [[ "${code}" != "201" ]]; then
    echo "ERROR: create token failed HTTP ${code}" >&2
    cat /tmp/gitea-bot-token.json >&2 || true
    exit 1
  fi
  python3 - <<'PY'
import json
data = json.load(open("/tmp/gitea-bot-token.json"))
sha = data.get("sha1") or data.get("token") or ""
if not sha:
    raise SystemExit("ERROR: token create response had no sha1")
open("/tmp/gitea-bot-token.sha1", "w").write(sha)
PY
}

write_secret() {
  python3 - <<PY
import json, base64
token = open("/tmp/gitea-bot-token.sha1").read().strip()
body = {"data": {"token": base64.b64encode(token.encode()).decode()}}
open("/tmp/gitea-bot-secret-patch.json", "w").write(json.dumps(body))
PY
  local code
  code="$(k8s_curl \
    -H "Content-Type: application/strategic-merge-patch+json" \
    -X PATCH \
    -o /tmp/k8s-secret-patch.json -w '%{http_code}' \
    "${K8S_API}/api/v1/namespaces/${RENOVATE_NAMESPACE}/secrets/${TOKEN_SECRET_NAME}" \
    --data-binary @/tmp/gitea-bot-secret-patch.json)"
  if [[ "${code}" == "200" ]]; then
    echo "Wrote Secret ${TOKEN_SECRET_NAME} (token not logged)"
    return 0
  fi
  echo "ERROR: patch Secret failed HTTP ${code}" >&2
  cat /tmp/k8s-secret-patch.json >&2 || true
  exit 1
}

ensure_collaborator() {
  local code
  code="$(curl -sS -o /tmp/gitea-collab.json -w '%{http_code}' \
    -X PUT \
    -H "$(admin_auth)" \
    -H 'Content-Type: application/json' \
    -d '{"permission":"write"}' \
    "${API}/repos/${TARGET_ORG}/${TARGET_REPO}/collaborators/${BOT_USER}" || true)"
  if [[ "${code}" == "204" || "${code}" == "200" ]]; then
    echo "Added ${BOT_USER} as write collaborator on ${TARGET_ORG}/${TARGET_REPO}"
    return 0
  fi
  if [[ "${code}" == "404" ]]; then
    echo "Repo ${TARGET_ORG}/${TARGET_REPO} not found yet — learner Module 2 seed will add the collaborator"
    return 0
  fi
  echo "WARN: add collaborator HTTP ${code}" >&2
  cat /tmp/gitea-collab.json >&2 || true
}

ensure_user
delete_named_token
mint_token
write_secret
ensure_collaborator
rm -f /tmp/gitea-bot-token.sha1 /tmp/gitea-bot-token.json
echo "renovate-bot-token: complete"
