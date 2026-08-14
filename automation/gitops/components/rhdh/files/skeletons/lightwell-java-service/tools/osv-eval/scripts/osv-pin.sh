#!/usr/bin/env bash
# Extract Maven package + .rhlw-* fixed version from an OSV JSON file (Module 3).
# Requires: jq
set -euo pipefail

OSV_FILE="${1:-}"
if [[ -z "${OSV_FILE}" || ! -f "${OSV_FILE}" ]]; then
  echo "Usage: $0 <osv.json>" >&2
  echo "Example: $0 tools/osv-eval/samples/LW-DEMO-0001.json" >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "ERROR: jq is required" >&2
  exit 1
fi

ecosystem="$(jq -r '.affected[0].package.ecosystem // empty' "${OSV_FILE}")"
name="$(jq -r '.affected[0].package.name // empty' "${OSV_FILE}")"
fixed="$(jq -r '
  .affected[0].ranges[]?
  | select(.type=="ECOSYSTEM")
  | .events[]?
  | select(has("fixed"))
  | .fixed
' "${OSV_FILE}" | head -1)"
base="$(jq -r '.database_specific.lightwell_base_version // .affected[0].versions[0] // empty' "${OSV_FILE}")"
group_id="$(jq -r '.database_specific.groupId // empty' "${OSV_FILE}")"
artifact_id="$(jq -r '.database_specific.artifactId // empty' "${OSV_FILE}")"

if [[ -z "${group_id}" && "${name}" == *:* ]]; then
  group_id="${name%%:*}"
  artifact_id="${name#*:}"
fi

if [[ "${ecosystem}" != "Maven" ]]; then
  echo "WARN: ecosystem is '${ecosystem}' (expected Maven)" >&2
fi

if [[ -z "${fixed}" || "${fixed}" != *".rhlw-"* ]]; then
  echo "ERROR: no Maven ECOSYSTEM fixed event with .rhlw-* suffix in ${OSV_FILE}" >&2
  exit 1
fi

cat <<EOF
osv_id=$(jq -r '.id' "${OSV_FILE}")
ecosystem=${ecosystem}
package=${name}
groupId=${group_id}
artifactId=${artifact_id}
base_version=${base}
fixed_version=${fixed}
pin_property_hint=${artifact_id}.version=${fixed}
EOF
