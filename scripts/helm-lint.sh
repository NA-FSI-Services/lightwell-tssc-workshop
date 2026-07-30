#!/usr/bin/env bash
# Lint Helm charts under charts/ (and optionally paths passed by pre-commit).
# Usage:
#   scripts/helm-lint.sh              # lint all charts/ Chart.yaml trees
#   scripts/helm-lint.sh <files...>   # lint unique chart roots for changed files
set -euo pipefail

if ! command -v helm >/dev/null 2>&1; then
  echo "helm is required for helm-lint (https://helm.sh/docs/intro/install/)" >&2
  exit 1
fi

chart_root_for() {
  local path="$1"
  local dir
  dir="$(dirname "$path")"
  while [[ "$dir" != "." && "$dir" != "/" ]]; do
    if [[ -f "${dir}/Chart.yaml" ]]; then
      printf '%s\n' "$dir"
      return 0
    fi
    dir="$(dirname "$dir")"
  done
  return 1
}

declare -a charts=()

if [[ "$#" -eq 0 ]]; then
  while IFS= read -r -d '' chart_yaml; do
    charts+=("$(dirname "$chart_yaml")")
  done < <(find charts -name Chart.yaml -print0 2>/dev/null || true)
else
  for file in "$@"; do
    if root="$(chart_root_for "$file")"; then
      charts+=("$root")
    fi
  done
fi

if [[ "${#charts[@]}" -eq 0 ]]; then
  echo "helm-lint: no charts to lint"
  exit 0
fi

# Unique chart directories (portable, no mapfile/associative arrays required)
unique_charts="$(printf '%s\n' "${charts[@]}" | sort -u)"
failed=0

while IFS= read -r chart; do
  [[ -z "$chart" ]] && continue
  echo "helm lint ${chart}"
  if ! helm lint "$chart"; then
    failed=1
  fi
done <<< "$unique_charts"

exit "$failed"
