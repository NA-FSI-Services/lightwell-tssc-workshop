#!/usr/bin/env bash
# Dispatch to per-module live-state checks (V2-54). Quiz keys are V2-59.
set -euo pipefail
# shellcheck disable=SC1091
source /opt/validate/helper.sh
module_begin
id="${MODULE_ID:?MODULE_ID is not set}"
script="/opt/validate/check-${id}.sh"
[[ -f "$script" ]] || fail "No live-state check script for module ${id}."
# shellcheck disable=SC1090
source "$script"
