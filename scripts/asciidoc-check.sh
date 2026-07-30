#!/usr/bin/env bash
# Structural checks for Showroom Antora content (docs/ + site.yml).
# Usage:
#   scripts/asciidoc-check.sh              # check full tree
#   scripts/asciidoc-check.sh <files...>   # same checks when any AsciiDoc/playbook path changes
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT}"

PAGES_DIR="docs/modules/ROOT/pages"
NAV="docs/modules/ROOT/nav.adoc"
ANTORA_YML="docs/antora.yml"
SITE_YML="site.yml"
SITE_CI_YML="site-ci.yml"

failed=0
warn() { echo "asciidoc-check: WARN: $*" >&2; }
err() { echo "asciidoc-check: ERROR: $*" >&2; failed=1; }

# If filenames were passed (pre-commit) but none are content-related, skip.
if [[ "$#" -gt 0 ]]; then
  relevant=0
  for f in "$@"; do
    case "$f" in
      docs/*|site.yml|site-ci.yml|scripts/asciidoc-check.sh) relevant=1; break ;;
    esac
  done
  if [[ "${relevant}" -eq 0 ]]; then
    echo "asciidoc-check: no AsciiDoc/Antora paths in this change set"
    exit 0
  fi
fi

echo "asciidoc-check: structural validation"

[[ -f "${SITE_YML}" ]] || err "missing ${SITE_YML} (Showroom antoraPlaybook)"
[[ -f "${SITE_CI_YML}" ]] || err "missing ${SITE_CI_YML} (CI Antora playbook)"
[[ -f "${ANTORA_YML}" ]] || err "missing ${ANTORA_YML}"
[[ -f "${NAV}" ]] || err "missing ${NAV}"
[[ -d "${PAGES_DIR}" ]] || err "missing ${PAGES_DIR}"

if [[ -f "${SITE_YML}" ]]; then
  if ! grep -qE 'start_path:[[:space:]]*docs' "${SITE_YML}"; then
    err "${SITE_YML} must set content.sources[].start_path: docs"
  fi
  if ! grep -qE 'start_page:[[:space:]]*modules::index\.adoc' "${SITE_YML}"; then
    err "${SITE_YML} must set site.start_page: modules::index.adoc"
  fi
fi

if [[ -f "${SITE_CI_YML}" ]]; then
  if ! grep -qE 'start_path:[[:space:]]*docs' "${SITE_CI_YML}"; then
    err "${SITE_CI_YML} must set content.sources[].start_path: docs"
  fi
fi

if [[ -f "${ANTORA_YML}" ]]; then
  if ! grep -qE 'name:[[:space:]]*modules' "${ANTORA_YML}"; then
    err "${ANTORA_YML} component name must be 'modules' (matches start_page modules::...)"
  fi
  if ! grep -qE 'modules/ROOT/nav\.adoc' "${ANTORA_YML}"; then
    err "${ANTORA_YML} must list modules/ROOT/nav.adoc under nav:"
  fi
fi

# Strip AsciiDoc block comments //// ... //// before collecting xrefs from nav.
strip_adoc_comments() {
  awk '
    /^\/\/\/\// { in_comment = !in_comment; next }
    !in_comment { print }
  ' "$1"
}

if [[ -f "${NAV}" ]]; then
  while IFS= read -r target; do
    [[ -z "${target}" ]] && continue
    # xref:page.adoc[label] or xref:module:page.adoc[label] — keep basename page.adoc
    page="${target##*:}"
    page="${page%%[*}"
    page="${page%%]*}"
    if [[ ! -f "${PAGES_DIR}/${page}" ]]; then
      err "nav.adoc xref target missing: ${page} (expected ${PAGES_DIR}/${page})"
    fi
  done < <(strip_adoc_comments "${NAV}" | grep -oE 'xref:[^\[\(]+' | sed 's/^xref://' || true)
fi

# include:: paths relative to the including file's directory (Antora partials/pages).
while IFS= read -r -d '' adoc; do
  dir="$(dirname "${adoc}")"
  while IFS= read -r inc; do
    [[ -z "${inc}" ]] && continue
    # strip optional attributes after [
    path="${inc%%[*}"
    # skip URL includes
    if [[ "${path}" == https:* || "${path}" == http:* ]]; then
      continue
    fi
    # Antora resource IDs like partial$foo.adoc — skip deep resolution
    if [[ "${path}" == *'$'* ]]; then
      continue
    fi
    if [[ ! -f "${dir}/${path}" && ! -f "${path}" ]]; then
      err "broken include in ${adoc}: ${path}"
    fi
  done < <(grep -oE 'include::[^[]+' "${adoc}" | sed 's/^include:://' || true)
done < <(find docs -name '*.adoc' -print0 2>/dev/null || true)

# Forbidden fictional channel / suffix names in GitOps config (not lab prose).
# Labs may mention these names while teaching learners not to invent them.
matches="$(
  grep -RInE -e 'upstream-untrusted' -e 'lightwell-network-secured' -e '-lw01([^0-9a-zA-Z]|$)' \
    charts agnosticv site.yml site-ci.yml 2>/dev/null \
    | grep -E '\.(ya?ml|yml|tpl|json):' || true
)"
if [[ -n "${matches}" ]]; then
  err "forbidden channel/suffix naming in config (use Validated/Remediated and .rhlw-* only):"
  echo "${matches}" >&2
fi

# Every page under ROOT/pages should be .adoc
while IFS= read -r -d '' f; do
  case "$f" in
    *.adoc) ;;
    *) err "non-AsciiDoc file in ${PAGES_DIR}: ${f}" ;;
  esac
done < <(find "${PAGES_DIR}" -type f -print0 2>/dev/null || true)

if [[ ! -f "${PAGES_DIR}/index.adoc" ]]; then
  err "missing ${PAGES_DIR}/index.adoc (site start_page)"
fi

if [[ "${failed}" -ne 0 ]]; then
  echo "asciidoc-check: FAILED" >&2
  exit 1
fi

echo "asciidoc-check: OK"
exit 0
