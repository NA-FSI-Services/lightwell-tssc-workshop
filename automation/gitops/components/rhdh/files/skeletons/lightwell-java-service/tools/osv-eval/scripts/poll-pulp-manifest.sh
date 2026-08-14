#!/usr/bin/env bash
# Instructor appendix — poll Lightwell Java OSV PULP_MANIFEST for new files.
# Generic automation hook only (print / optional webhook). No customer ITSM.
#
# Canonical OSV remote:
#   https://packages.redhat.com/lightwell/osv/java/remediated
#
# Ansible/AAP-style equivalent: uri module → get PULP_MANIFEST → compare checksum
# → create ticket / trigger pipeline (map to your org's tooling separately).
set -euo pipefail

OSV_BASE="${OSV_BASE:-https://packages.redhat.com/lightwell/osv/java/remediated}"
STATE_DIR="${STATE_DIR:-${HOME}/.cache/lightwell-osv-eval}"
MANIFEST_URL="${OSV_BASE%/}/PULP_MANIFEST"
WEBHOOK_URL="${WEBHOOK_URL:-}"
INTERVAL_SEC="${INTERVAL_SEC:-0}"  # 0 = single shot

mkdir -p "${STATE_DIR}"
PREV="${STATE_DIR}/PULP_MANIFEST.sha256"
CUR_FILE="${STATE_DIR}/PULP_MANIFEST"

curl_manifest() {
  local args=(-fsSL)
  if [[ -n "${LW_USERNAME:-}" && -n "${LW_PASSWORD:-}" ]]; then
    args+=(-u "${LW_USERNAME}:${LW_PASSWORD}")
  fi
  curl "${args[@]}" -o "${CUR_FILE}" "${MANIFEST_URL}"
}

notify() {
  local msg="$1"
  echo "${msg}"
  if [[ -n "${WEBHOOK_URL}" ]]; then
    curl -fsSL -X POST -H 'Content-Type: application/json' \
      -d "{\"text\":$(python3 -c "import json,sys; print(json.dumps(sys.argv[1]))" "${msg}")}" \
      "${WEBHOOK_URL}" || echo "WARN: webhook failed" >&2
  fi
}

once() {
  echo "Polling ${MANIFEST_URL}"
  if ! curl_manifest; then
    echo "ERROR: could not fetch PULP_MANIFEST (auth? network?). For labs use seeded OSV JSON instead." >&2
    exit 1
  fi
  local sum
  sum="$(sha256sum "${CUR_FILE}" | awk '{print $1}')"
  echo "sha256=${sum} lines=$(wc -l < "${CUR_FILE}")"

  if [[ ! -f "${PREV}" ]]; then
    echo "${sum}" > "${PREV}"
    notify "Initialized OSV PULP_MANIFEST watch (${sum:0:12}…)"
    return 0
  fi

  local old
  old="$(cat "${PREV}")"
  if [[ "${old}" != "${sum}" ]]; then
    echo "${sum}" > "${PREV}"
    notify "NEW OSV content detected in PULP_MANIFEST (was ${old:0:12}… now ${sum:0:12}…). Hook: open ticket / trigger rebuild pipeline."
    # Show first few new-looking paths (best-effort)
    head -20 "${CUR_FILE}" || true
    return 2
  fi
  echo "No change"
  return 0
}

if [[ "${INTERVAL_SEC}" -gt 0 ]]; then
  while true; do
    once || true
    sleep "${INTERVAL_SEC}"
  done
else
  once
fi
