#!/usr/bin/env bash
# Assemble student GitOps chart repo: monorepo chart minus ./app (#100 S1 / #147).
#
# Env:
#   SOURCE_MODE, SOURCE_REPO_URL, SOURCE_REVISION, GITOPS_SOURCE_PATH
#   OVERLAY_GITOPS_PREFIX=overlay-gitops|overlay-python-gitops (default overlay-gitops)
set -euo pipefail

ROOT="${1:-/tmp/gitea-seed/gitops-repo}"
mkdir -p "${ROOT}"

SOURCE_MODE="${SOURCE_MODE:-live}"
SOURCE_REPO_URL="${SOURCE_REPO_URL:-}"
SOURCE_REVISION="${SOURCE_REVISION:-main}"
GITOPS_SOURCE_PATH="${GITOPS_SOURCE_PATH:-charts/components/spring-boot-lw-poc}"
SEED_MOUNT="${SEED_MOUNT:-/seed}"
OVERLAY_GITOPS_PREFIX="${OVERLAY_GITOPS_PREFIX:-overlay-gitops}"

isolate_gitops_chart() {
  if [[ -z "${SOURCE_REPO_URL}" ]]; then
    echo "ERROR: live gitops assemble requires SOURCE_REPO_URL" >&2
    exit 1
  fi

  local clone_dir
  clone_dir="$(mktemp -d)"
  echo "Cloning ${SOURCE_REPO_URL} @ ${SOURCE_REVISION} for gitops chart isolation ..."
  local url="${SOURCE_REPO_URL}"
  if [[ -n "${SOURCE_GIT_USERNAME:-}" && -n "${SOURCE_GIT_PASSWORD:-}" ]]; then
    local hostpath="${SOURCE_REPO_URL#https://}"
    hostpath="${hostpath#http://}"
    url="https://${SOURCE_GIT_USERNAME}:${SOURCE_GIT_PASSWORD}@${hostpath}"
  fi

  GIT_TERMINAL_PROMPT=0 git -c http.sslVerify="${SOURCE_GIT_SSL_VERIFY:-true}" \
    clone --depth 1 --branch "${SOURCE_REVISION}" "${url}" "${clone_dir}/src" \
    || GIT_TERMINAL_PROMPT=0 git -c http.sslVerify="${SOURCE_GIT_SSL_VERIFY:-true}" \
      clone --depth 1 "${url}" "${clone_dir}/src"

  local src="${clone_dir}/src/${GITOPS_SOURCE_PATH}"
  if [[ ! -d "${src}" ]]; then
    echo "ERROR: gitops source path not found: ${GITOPS_SOURCE_PATH}" >&2
    exit 1
  fi

  echo "Isolating ${GITOPS_SOURCE_PATH} (excluding app/) → gitops repo root"
  cp -a "${src}/." "${ROOT}/"
  # Never expose app sources on the gitops remote (S1)
  rm -rf "${ROOT}/app"
  rm -rf "${clone_dir}"
}

apply_gitops_overlay() {
  if [[ -f "${SEED_MOUNT}/${OVERLAY_GITOPS_PREFIX}-README.md" ]]; then
    cp "${SEED_MOUNT}/${OVERLAY_GITOPS_PREFIX}-README.md" "${ROOT}/README.md"
  fi
  if [[ -f "${SEED_MOUNT}/${OVERLAY_GITOPS_PREFIX}-PROMOTE.md" ]]; then
    cp "${SEED_MOUNT}/${OVERLAY_GITOPS_PREFIX}-PROMOTE.md" "${ROOT}/PROMOTE.md"
  fi
}

patch_gitops_values() {
  local values="${ROOT}/values.yaml"
  [[ -f "${values}" ]] || return 0
  # Disable duplicate RHDP surfaces; keep replicas:0 / empty digest for Healthy pre-promote
  python3 - "${values}" <<'PY'
import pathlib, sys
p = pathlib.Path(sys.argv[1])
text = p.read_text()
for a, b in (
    ("labDocs:\n  enabled: true", "labDocs:\n  enabled: false"),
    ("userInfo:\n  enabled: true", "userInfo:\n  enabled: false"),
):
    if a in text:
        text = text.replace(a, b, 1)
if "digest:" not in text:
    text = text.replace("tag: latest\n", "tag: latest\n  digest: \"\"\n", 1)
p.write_text(text)
print(f"patched {p}")
PY
}

case "${SOURCE_MODE}" in
  live)
    isolate_gitops_chart
    ;;
  embedded)
    echo "ERROR: gitops seed requires SOURCE_MODE=live (chart isolation from monorepo)" >&2
    exit 1
    ;;
  *)
    echo "ERROR: unknown SOURCE_MODE=${SOURCE_MODE}" >&2
    exit 1
    ;;
esac

apply_gitops_overlay
patch_gitops_values

echo "Assembled gitops repo at ${ROOT}:"
find "${ROOT}" -maxdepth 3 -type f | sort | head -60
