#!/usr/bin/env bash
# oc login using gitignored dev-cluster/claim.env
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
: "${OC_TOKEN:?OC_TOKEN required in claim.env}"

if ! command -v oc >/dev/null 2>&1; then
  echo "dev-cluster-login: oc not found on PATH" >&2
  exit 1
fi

login_args=(--server="${API_URL}" --token="${OC_TOKEN}")
if [[ -n "${OC_CA_FILE:-}" ]]; then
  if [[ ! -f "${OC_CA_FILE}" ]]; then
    echo "dev-cluster-login: OC_CA_FILE not found: ${OC_CA_FILE}" >&2
    exit 1
  fi
  login_args+=(--certificate-authority="${OC_CA_FILE}")
else
  echo "dev-cluster-login: WARN: OC_CA_FILE unset — using insecure skip if needed" >&2
  login_args+=(--insecure-skip-tls-verify=true)
fi

oc login "${login_args[@]}"
oc whoami
oc whoami --show-server
oc get nodes -o wide || true

echo "dev-cluster-login: OK (DEPLOYER_DOMAIN=${DEPLOYER_DOMAIN:-unset})"
