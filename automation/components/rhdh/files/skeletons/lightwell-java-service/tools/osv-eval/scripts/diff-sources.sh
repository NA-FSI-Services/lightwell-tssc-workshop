#!/usr/bin/env bash
# Fetch (or use fixtures for) upstream vs Lightwell-remediated -sources.jar and diff.
# Uses git diff --no-index (Showroom terminal has git, not GNU diffutils).
# Does not require customer systems — fixtures mode is the RHDP default.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORKDIR="${WORKDIR:-$(mktemp -d -t lightwell-osv-diff.XXXXXX)}"
MODE="fixture"
OSV_FILE="${ROOT}/samples/LW-DEMO-0001.json"
UPSTREAM_BASE=""
REMEDIATED_BASE=""
GROUP_ID=""
ARTIFACT_ID=""
BASE_VER=""
FIXED_VER=""

usage() {
  cat <<EOF
Usage: $0 [--fixture|--fetch] [--osv FILE] [--workdir DIR]

  --fixture   Diff local fixtures (default; offline / Showroom-friendly)
  --fetch     Download *-sources.jar from Maven remotes (needs network + optional LW_*)
  --osv FILE  OSV JSON used to discover GAV / .rhlw-* pin (default: samples/LW-DEMO-0001.json)
  --workdir   Scratch directory (default: mktemp)

Diff tool: git --no-pager diff --no-index (required; present in Showroom terminal).

Fetch mode remotes:
  LIGHTWELL_NEXUS_URL   Enterprise Nexus base (preferred in workshop)
  or packages.redhat.com with LW_USERNAME / LW_PASSWORD
  Maven Central used as fallback for the non-remediated base version only.

Examples:
  $0 --fixture
  LIGHTWELL_NEXUS_URL=https://nexus-lightwell-repo.apps.example.com $0 --fetch
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --fixture) MODE=fixture; shift ;;
    --fetch) MODE=fetch; shift ;;
    --osv) OSV_FILE="$2"; shift 2 ;;
    --workdir) WORKDIR="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; usage; exit 1 ;;
  esac
done

load_pin() {
  # shellcheck disable=SC1090
  eval "$("${ROOT}/scripts/osv-pin.sh" "${OSV_FILE}")"
  GROUP_ID="${groupId}"
  ARTIFACT_ID="${artifactId}"
  BASE_VER="${base_version}"
  FIXED_VER="${fixed_version}"
}

maven_path() {
  local g="$1" a="$2" v="$3"
  echo "${g//.//}/${a}/${v}/${a}-${v}-sources.jar"
}

curl_auth() {
  local url="$1" out="$2"
  local args=(-fsSL)
  if [[ -n "${LW_USERNAME:-}" && -n "${LW_PASSWORD:-}" ]]; then
    args+=(-u "${LW_USERNAME}:${LW_PASSWORD}")
  fi
  curl "${args[@]}" -o "${out}" "${url}"
}

fetch_sources() {
  local version="$1" dest="$2" prefer_lwn="$3"
  local rel path url
  rel="$(maven_path "${GROUP_ID}" "${ARTIFACT_ID}" "${version}")"
  mkdir -p "$(dirname "${dest}")"

  if [[ -n "${LIGHTWELL_NEXUS_URL:-}" ]]; then
    local repo="lightwell-java-validated"
    if [[ "${prefer_lwn}" == "remediated" ]]; then
      repo="lightwell-java-remediated"
    fi
    url="${LIGHTWELL_NEXUS_URL%/}/repository/${repo}/${rel}"
    echo "GET ${url}"
    if curl_auth "${url}" "${dest}"; then
      return 0
    fi
    echo "WARN: Nexus fetch failed for ${version}" >&2
  fi

  if [[ "${prefer_lwn}" == "remediated" ]]; then
    url="https://packages.redhat.com/lightwell/java/remediated/${rel}"
  else
    url="https://packages.redhat.com/lightwell/java/validated/${rel}"
  fi
  echo "GET ${url}"
  if curl_auth "${url}" "${dest}"; then
    return 0
  fi

  if [[ "${prefer_lwn}" != "remediated" ]]; then
    url="https://repo.maven.apache.org/maven2/${rel}"
    echo "GET ${url} (Central fallback)"
    curl -fsSL -o "${dest}" "${url}"
    return 0
  fi

  echo "ERROR: could not download remediated sources for ${version}" >&2
  echo "Hint: use --fixture for offline labs, or seed Nexus (#11) with *-sources.jar" >&2
  return 1
}

unpack_jar() {
  local jar="$1" out="$2"
  mkdir -p "${out}"
  if command -v jar >/dev/null 2>&1; then
    (cd "${out}" && jar xf "${jar}")
  else
    unzip -q -o "${jar}" -d "${out}"
  fi
}

# Showroom terminal ships git but not GNU diffutils — prefer git diff --no-index.
# Exit: 0 identical, 1 differences (expected for fixtures), >=2 tool failure.
# Do not toggle set -e here — returning 1 under set -e aborts the caller.
run_tree_diff() {
  local left="$1" right="$2" rc=0
  if ! command -v git >/dev/null 2>&1; then
    echo "ERROR: git is required for source diffs (Showroom has git; install git if local)." >&2
    return 127
  fi
  echo "git --no-pager diff --no-index -- ${left} ${right}"
  git --no-pager diff --no-index -- "${left}" "${right}" && rc=0 || rc=$?
  if [[ "${rc}" -gt 1 ]]; then
    echo "ERROR: git diff failed (exit ${rc})" >&2
    return "${rc}"
  fi
  return "${rc}"
}

run_fixture() {
  echo "=== Fixture mode (offline Module 3 demo) ==="
  echo "OSV: ${OSV_FILE}"
  load_pin
  echo "Pin: ${GROUP_ID}:${ARTIFACT_ID}:${BASE_VER} → ${FIXED_VER}"
  local left="${ROOT}/fixtures/upstream"
  local right="${ROOT}/fixtures/remediated"
  local rc=0
  run_tree_diff "${left}" "${right}" && rc=0 || rc=$?
  if [[ "${rc}" -gt 1 ]]; then
    return "${rc}"
  fi
  if [[ "${rc}" -eq 0 ]]; then
    echo "WARN: no differences (unexpected for demo fixtures)" >&2
  else
    echo "---"
    echo "OK: source diff shows remediated changes for narrative pin ${FIXED_VER}"
  fi
  return 0
}

run_fetch() {
  echo "=== Fetch mode (upstream vs remediated -sources.jar) ==="
  load_pin
  echo "Workdir: ${WORKDIR}"
  mkdir -p "${WORKDIR}/jars" "${WORKDIR}/upstream" "${WORKDIR}/remediated"

  local up_jar="${WORKDIR}/jars/${ARTIFACT_ID}-${BASE_VER}-sources.jar"
  local rem_jar="${WORKDIR}/jars/${ARTIFACT_ID}-${FIXED_VER}-sources.jar"

  fetch_sources "${BASE_VER}" "${up_jar}" "validated"
  fetch_sources "${FIXED_VER}" "${rem_jar}" "remediated"

  unpack_jar "${up_jar}" "${WORKDIR}/upstream"
  unpack_jar "${rem_jar}" "${WORKDIR}/remediated"

  local rc=0
  run_tree_diff "${WORKDIR}/upstream" "${WORKDIR}/remediated" && rc=0 || rc=$?
  echo "---"
  echo "Jars kept under ${WORKDIR}/jars"
  if [[ "${rc}" -gt 1 ]]; then
    return "${rc}"
  fi
  return 0
}

main() {
  if [[ ! -x "${ROOT}/scripts/osv-pin.sh" ]]; then
    chmod +x "${ROOT}/scripts/osv-pin.sh" || true
  fi
  case "${MODE}" in
    fixture) run_fixture ;;
    fetch) run_fetch ;;
    *) echo "bad mode"; exit 1 ;;
  esac
}

main "$@"
