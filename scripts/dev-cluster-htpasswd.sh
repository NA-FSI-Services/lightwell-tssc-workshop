#!/usr/bin/env bash
# Create an HTPasswd Identity Provider + cluster-admin user on an ephemeral claim.
# Intended for dev-cluster QA (kubeadmin/token bootstrap → stable admin login).
# Never commit passwords. Prefer claim.env (gitignored).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT}"

CLAIM_ENV="${CLAIM_ENV:-${ROOT}/dev-cluster/claim.env}"

if [[ ! -f "${CLAIM_ENV}" ]]; then
  echo "dev-cluster-htpasswd: missing ${CLAIM_ENV}" >&2
  echo "Copy dev-cluster/claim.env.example → claim.env and fill HTPASSWD_* vars." >&2
  exit 1
fi

set -a
# shellcheck disable=SC1090
source "${CLAIM_ENV}"
set +a

HTPASSWD_ADMIN_USER="${HTPASSWD_ADMIN_USER:-admin}"
HTPASSWD_ADMIN_PASSWORD="${HTPASSWD_ADMIN_PASSWORD:-}"
HTPASSWD_SECRET_NAME="${HTPASSWD_SECRET_NAME:-htpasswd-secret}"
HTPASSWD_IDP_NAME="${HTPASSWD_IDP_NAME:-htpasswd_provider}"
WAIT_OAUTH_SECONDS="${WAIT_OAUTH_SECONDS:-180}"

if [[ -z "${HTPASSWD_ADMIN_PASSWORD}" ]]; then
  echo "dev-cluster-htpasswd: HTPASSWD_ADMIN_PASSWORD required in claim.env" >&2
  exit 1
fi

if ! command -v oc >/dev/null 2>&1; then
  echo "dev-cluster-htpasswd: oc not found on PATH" >&2
  exit 1
fi

if ! command -v htpasswd >/dev/null 2>&1; then
  echo "dev-cluster-htpasswd: htpasswd not found (install httpd/apache2-utils)" >&2
  exit 1
fi

if ! oc whoami >/dev/null 2>&1; then
  echo "dev-cluster-htpasswd: not logged in — run ./scripts/dev-cluster-login.sh first" >&2
  exit 1
fi

if ! oc auth can-i patch oauth --all-namespaces >/dev/null 2>&1; then
  echo "dev-cluster-htpasswd: current user cannot patch OAuth (need cluster-admin)" >&2
  exit 1
fi

tmp="$(mktemp -d)"
trap 'rm -rf "${tmp}"' EXIT

# bcrypt (-B) is supported by OpenShift HTPasswd IdP
htpasswd -Bbn "${HTPASSWD_ADMIN_USER}" "${HTPASSWD_ADMIN_PASSWORD}" > "${tmp}/users.htpasswd"

oc create secret generic "${HTPASSWD_SECRET_NAME}" \
  --from-file=htpasswd="${tmp}/users.htpasswd" \
  -n openshift-config \
  --dry-run=client -o yaml | oc apply -f -

# Replace identityProviders with HTPasswd (dev claims typically have empty OAuth spec).
# If you need to preserve other IdPs, edit OAuth manually after this script.
oc patch oauth cluster --type=merge -p "$(cat <<EOF
{
  "spec": {
    "identityProviders": [
      {
        "name": "${HTPASSWD_IDP_NAME}",
        "mappingMethod": "claim",
        "type": "HTPasswd",
        "htpasswd": {
          "fileData": {
            "name": "${HTPASSWD_SECRET_NAME}"
          }
        }
      }
    ]
  }
}
EOF
)"

oc adm policy add-cluster-role-to-user cluster-admin "${HTPASSWD_ADMIN_USER}" >/dev/null

echo "dev-cluster-htpasswd: waiting for oauth-openshift (up to ${WAIT_OAUTH_SECONDS}s)"
oc -n openshift-authentication rollout status deployment/oauth-openshift --timeout="${WAIT_OAUTH_SECONDS}s" \
  || echo "dev-cluster-htpasswd: WARN: oauth rollout status timed out — retry login shortly"

echo "dev-cluster-htpasswd: OK"
echo "  IdP: ${HTPASSWD_IDP_NAME}"
echo "  User: ${HTPASSWD_ADMIN_USER} (cluster-admin)"
echo "  Login: oc login \${API_URL} -u ${HTPASSWD_ADMIN_USER} -p '***' --certificate-authority=\${OC_CA_FILE}"
echo "  Or: ./scripts/dev-cluster-login.sh  (set OC_LOGIN_MODE=password in claim.env)"
