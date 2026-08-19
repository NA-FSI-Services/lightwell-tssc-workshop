#!/usr/bin/env bash
# Shared Validate Job helper (V2-51). Teaching fails only. No Solve.

set -euo pipefail

VALIDATE_NS="${VALIDATE_NS:-lw-poc-validate}"

fail() {
  echo "CHECK FAILED: $*" >&2
  echo "Honor system: fix the named object, then re-run this Job (delete + create from validate-job-templates). There is no Solve." >&2
  exit 1
}

pass() {
  echo "CHECK PASSED: $*"
  exit 0
}

not_implemented() {
  fail "$* This scaffold does not grade track state yet (V2-54). Report keys ship in V2-59. A stub fail is not a completed Check."
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "Missing command '$1' in the Validate Job image."
}

cm_get() {
  local ns="$1" name="$2" key="$3"
  oc -n "$ns" get configmap "$name" -o "jsonpath={.data['${key}']}" 2>/dev/null || true
}

report_name() {
  echo "${REPORT_NAME:?REPORT_NAME is not set}"
}

report_get() {
  local key="$1"
  cm_get "$VALIDATE_NS" "$(report_name)" "$key"
}

report_require_key() {
  local key="$1"
  local value
  value="$(report_get "$key")"
  [[ -n "$value" ]] || fail "Report $(report_name) is missing key '${key}'. oc -n ${VALIDATE_NS} edit configmap $(report_name)"
  case "$value" in
    REPLACE_ME*) fail "Report $(report_name) key '${key}' is still a placeholder. Replace REPLACE_ME; do not copy validate-docs." ;;
  esac
}

module_begin() {
  require_cmd oc
  echo "=== Validate Job ${MODULE_ID:-?} — ${MODULE_TITLE:-unknown} ==="
  oc -n "$VALIDATE_NS" get configmap "$(report_name)" >/dev/null \
    || fail "Report ConfigMap $(report_name) is missing in ${VALIDATE_NS}."
}
