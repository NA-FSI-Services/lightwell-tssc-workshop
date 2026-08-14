#!/usr/bin/env bash
# Isolate RHDH Software Template skeleton into a Gitea template repo root.
# Operators clone the workshop GitOps URL; learners / RHDH fetch from workshop-templates.
set -euo pipefail

ROOT="${1:-/tmp/gitea-seed/skeleton}"
mkdir -p "${ROOT}"

SOURCE_MODE="${SOURCE_MODE:-live}"
SOURCE_REPO_URL="${SOURCE_REPO_URL:-}"
SOURCE_REVISION="${SOURCE_REVISION:-main}"
SKELETON_PATH="${SKELETON_PATH:-charts/components/rhdh/files/skeletons/lightwell-java-service}"
SEED_MOUNT="${SEED_MOUNT:-/seed}"

if [[ "${SOURCE_MODE}" != "live" ]]; then
  echo "WARNING: skeleton assemble requires SOURCE_MODE=live (skipping)" >&2
  exit 0
fi

if [[ -z "${SOURCE_REPO_URL}" ]]; then
  echo "ERROR: assemble-skeleton requires SOURCE_REPO_URL" >&2
  exit 1
fi

clone_dir="$(mktemp -d)"
trap 'rm -rf "${clone_dir}"' EXIT

echo "Cloning ${SOURCE_REPO_URL} @ ${SOURCE_REVISION} for RHDH skeleton (operator seed only) ..."
url="${SOURCE_REPO_URL}"
if [[ -n "${SOURCE_GIT_USERNAME:-}" && -n "${SOURCE_GIT_PASSWORD:-}" ]]; then
  hostpath="${SOURCE_REPO_URL#https://}"
  hostpath="${hostpath#http://}"
  url="https://${SOURCE_GIT_USERNAME}:${SOURCE_GIT_PASSWORD}@${hostpath}"
fi

GIT_TERMINAL_PROMPT=0 git -c http.sslVerify="${SOURCE_GIT_SSL_VERIFY:-true}" \
  clone --depth 1 --branch "${SOURCE_REVISION}" "${url}" "${clone_dir}/src" \
  || GIT_TERMINAL_PROMPT=0 git -c http.sslVerify="${SOURCE_GIT_SSL_VERIFY:-true}" \
    clone --depth 1 "${url}" "${clone_dir}/src"

if [[ "${SOURCE_REVISION}" != "main" && "${SOURCE_REVISION}" != "master" ]]; then
  git -C "${clone_dir}/src" checkout "${SOURCE_REVISION}" 2>/dev/null || true
fi

src="${clone_dir}/src/${SKELETON_PATH}"
if [[ ! -d "${src}" ]]; then
  echo "ERROR: skeleton path not found: ${SKELETON_PATH}" >&2
  exit 1
fi

echo "Isolating ${SKELETON_PATH} → template skeleton repo root"
cp -a "${src}/." "${ROOT}/"

echo "Assembled RHDH skeleton at ${ROOT}:"
find "${ROOT}" -maxdepth 3 -type f | sort | head -40
