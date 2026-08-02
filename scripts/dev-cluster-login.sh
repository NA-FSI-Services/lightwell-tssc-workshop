#!/usr/bin/env bash
# oc login using gitignored dev-cluster/claim.env
# Supports OC_TOKEN (default) or HTPasswd password login (OC_LOGIN_MODE=password).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT}"

CLAIM_ENV="${CLAIM_ENV:-${ROOT}/dev-cluster/claim.env}"

if [[ ! -f "${CLAIM_ENV}" ]]; then
  echo "dev-cluster-login: missing ${CLAIM_ENV}" >&2
  echo "Copy dev-cluster/claim.env.example → claim.env and fill from the RHDP email." >&2
  exit 1
fi

set -a
# shellcheck disable=SC1090
source "${CLAIM_ENV}"
set +a

: "${API_URL:?API_URL required in claim.env}"

if ! command -v oc >/dev/null 2>&1; then
  echo "dev-cluster-login: oc not found on PATH" >&2
  exit 1
fi

OC_LOGIN_MODE="${OC_LOGIN_MODE:-token}"

ca_args=()
if [[ -n "${OC_CA_FILE:-}" ]]; then
  if [[ ! -f "${OC_CA_FILE}" ]]; then
    echo "dev-cluster-login: OC_CA_FILE not found: ${OC_CA_FILE}" >&2
    exit 1
  fi
  ca_args=(--certificate-authority="${OC_CA_FILE}")
else
  echo "dev-cluster-login: WARN: OC_CA_FILE unset — using insecure skip if needed" >&2
  ca_args=(--insecure-skip-tls-verify=true)
fi

case "${OC_LOGIN_MODE}" in
  token)
    : "${OC_TOKEN:?OC_TOKEN required in claim.env when OC_LOGIN_MODE=token}"
    oc login --server="${API_URL}" --token="${OC_TOKEN}" "${ca_args[@]}"
    ;;
  password)
    HTPASSWD_ADMIN_USER="${HTPASSWD_ADMIN_USER:-admin}"
    : "${HTPASSWD_ADMIN_PASSWORD:?HTPASSWD_ADMIN_PASSWORD required when OC_LOGIN_MODE=password}"
    # OAuth IdP can 401 for a short window after creation — retry briefly
    attempts="${OC_LOGIN_RETRIES:-8}"
    delay="${OC_LOGIN_RETRY_SECONDS:-10}"
    ok=0
    for ((i = 1; i <= attempts; i++)); do
      if oc login "${API_URL}" \
        -u "${HTPASSWD_ADMIN_USER}" \
        -p "${HTPASSWD_ADMIN_PASSWORD}" \
        "${ca_args[@]}"; then
        ok=1
        break
      fi
      echo "dev-cluster-login: password login attempt ${i}/${attempts} failed; retry in ${delay}s" >&2
      sleep "${delay}"
    done
    if [[ "${ok}" -ne 1 ]]; then
      echo "dev-cluster-login: password login failed — ensure ./scripts/dev-cluster-htpasswd.sh ran and OAuth rolled out" >&2
      exit 1
    fi
    ;;
  *)
    echo "dev-cluster-login: unknown OC_LOGIN_MODE=${OC_LOGIN_MODE} (use token|password)" >&2
    exit 1
    ;;
esac

oc whoami
oc whoami --show-server
oc get nodes -o wide || true

echo "dev-cluster-login: OK (mode=${OC_LOGIN_MODE} DEPLOYER_DOMAIN=${DEPLOYER_DOMAIN:-unset})"
