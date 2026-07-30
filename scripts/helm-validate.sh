#!/usr/bin/env bash
# Lint and template every Helm chart under charts/.
# Used by local validation and .github/workflows/helm-validate.yml.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if ! command -v helm >/dev/null 2>&1; then
  echo "helm is required (https://helm.sh/docs/intro/install/)" >&2
  exit 1
fi

DEPLOYER_DOMAIN="${DEPLOYER_DOMAIN:-apps.ci.example.com}"
DEPLOYER_API_URL="${DEPLOYER_API_URL:-https://api.ci.example.com:6443}"

charts=()
while IFS= read -r -d '' chart_yaml; do
  charts+=("$(dirname "$chart_yaml")")
done < <(find charts -name Chart.yaml -print0 2>/dev/null || true)

if [[ "${#charts[@]}" -eq 0 ]]; then
  echo "helm-validate: no charts found under charts/"
  exit 1
fi

failed=0
while IFS= read -r chart; do
  [[ -z "$chart" ]] && continue
  name="$(basename "$chart")"
  echo "==> helm lint ${chart}"
  if ! helm lint "$chart"; then
    failed=1
    continue
  fi
  echo "==> helm template ${chart}"
  if ! helm template "ci-${name}" "$chart" \
    --set "deployer.domain=${DEPLOYER_DOMAIN}" \
    --set "deployer.apiUrl=${DEPLOYER_API_URL}" \
    >/dev/null; then
    failed=1
  fi
done < <(printf '%s\n' "${charts[@]}" | sort -u)

exit "$failed"
