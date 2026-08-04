#!/usr/bin/env bash
# Showroom ↔ content contract (issue #19).
# Validates Helm values / chart templates stay aligned with site.yml and Modules 1–5.
#
# Usage:
#   scripts/showroom-check.sh
#   scripts/showroom-check.sh <files...>   # skip if change set unrelated
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT}"

SHOWROOM_CHART="charts/components/showroom"
SHOWROOM_VALUES="${SHOWROOM_CHART}/values.yaml"
ROOT_VALUES="charts/root-app/values.yaml"
SITE_YML="site.yml"
PAGES_DIR="docs/modules/ROOT/pages"

EXPECTED_CONTENT_IMAGE="quay.io/rhpds/showroom-content:v1.3.1"
EXPECTED_TERMINAL_IMAGE="quay.io/rhpds/openshift-showroom-terminal-ocp:latest"
EXPECTED_PLAYBOOK="site.yml"
EXPECTED_REPO="https://github.com/NA-FSI-Services/lightwell-tssc-workshop.git"

REQUIRED_MODULES=(
  module-01-overview.adoc
  module-02-maven.adoc
  module-03-osv.adoc
  module-04-sbom.adoc
  module-05-pipeline.adoc
  index.adoc
  appendix-lightwell-concepts.adoc
  appendix-acronyms.adoc
  rhda-shift-left.adoc
  appendix-osv-manifest-polling.adoc
)

failed=0
err() { echo "showroom-check: ERROR: $*" >&2; failed=1; }
ok() { echo "showroom-check: $*"; }

has_line() {
  local file="$1" pattern="$2"
  grep -qE "${pattern}" "${file}"
}

nookbag_enabled_in() {
  # True if a nookbag: block is followed (within 6 lines) by enabled: true
  local file="$1" lineno
  while IFS=: read -r lineno _; do
    [[ -z "${lineno}" ]] && continue
    if sed -n "${lineno},$((lineno + 6))p" "${file}" | grep -qE '^[[:space:]]+enabled:[[:space:]]*true[[:space:]]*$'; then
      return 0
    fi
  done < <(grep -nE '^[[:space:]]*nookbag:[[:space:]]*$' "${file}" || true)
  return 1
}

# pre-commit: skip when no Showroom/content-related paths changed
if [[ "$#" -gt 0 ]]; then
  relevant=0
  for f in "$@"; do
    case "$f" in
      charts/components/showroom/*|charts/root-app/values.yaml|charts/root-app/templates/applications.yaml|site.yml|site-ci.yml|ui-config.yml|docs/*|scripts/showroom-check.sh|docs/SHOWROOM-UPDATE-SPEC.md)
        relevant=1
        break
        ;;
    esac
  done
  if [[ "${relevant}" -eq 0 ]]; then
    echo "showroom-check: no Showroom/content paths in this change set"
    exit 0
  fi
fi

ok "validating Showroom ↔ content contract"

[[ -f "${SITE_YML}" ]] || err "missing ${SITE_YML} (Showroom antoraPlaybook)"
[[ -f "ui-config.yml" ]] || err "missing ui-config.yml (Showroom split-screen tabs)"
[[ -d "${SHOWROOM_CHART}" ]] || err "missing ${SHOWROOM_CHART}"
[[ -f "${SHOWROOM_VALUES}" ]] || err "missing ${SHOWROOM_VALUES}"
[[ -f "${ROOT_VALUES}" ]] || err "missing ${ROOT_VALUES}"

has_line "ui-config.yml" 'default_mode:[[:space:]]*split' \
  || err "ui-config.yml: view_switcher.default_mode must be split"
has_line "ui-config.yml" 'path:[[:space:]]*/terminal/' \
  || err "ui-config.yml: Terminal tab must use path: /terminal/"
if grep -qiE 'name:[[:space:]]*OpenShift Console' ui-config.yml; then
  err "ui-config.yml: remove OpenShift Console tab (iframe blocked by X-Frame-Options)"
fi
grep -qF 'sso.${DOMAIN}' ui-config.yml \
  || err "ui-config.yml: SSO (Keycloak) tab must use https://sso.\${DOMAIN}/..."
grep -qF 'server-trusted-profile-analyzer.${DOMAIN}' ui-config.yml \
  || err "ui-config.yml: RHTPA tab must use server-trusted-profile-analyzer.\${DOMAIN}"
grep -qF 'nexus-lightwell-repo.${DOMAIN}' ui-config.yml \
  || err "ui-config.yml: Nexus tab must use nexus-lightwell-repo.\${DOMAIN}"
grep -cE 'external:[[:space:]]*true' ui-config.yml | awk \
  '{ if ($1 < 3) exit 1 }' \
  || err "ui-config.yml: SSO/RHTPA/Nexus tabs must set external: true (open outside iframe)"

# --- Child chart values ---
if [[ -f "${SHOWROOM_VALUES}" ]]; then
  has_line "${SHOWROOM_VALUES}" "antoraPlaybook:[[:space:]]*[\"']?${EXPECTED_PLAYBOOK}[\"']?" \
    || err "${SHOWROOM_VALUES}: content.antoraPlaybook must be ${EXPECTED_PLAYBOOK}"
  grep -qF "${EXPECTED_REPO}" "${SHOWROOM_VALUES}" \
    || err "${SHOWROOM_VALUES}: content.repoUrl must be ${EXPECTED_REPO}"
  grep -qF "${EXPECTED_CONTENT_IMAGE}" "${SHOWROOM_VALUES}" \
    || err "${SHOWROOM_VALUES}: content.image must be ${EXPECTED_CONTENT_IMAGE} (SHOWROOM-UPDATE-SPEC)"
  grep -qF "${EXPECTED_TERMINAL_IMAGE}" "${SHOWROOM_VALUES}" \
    || err "${SHOWROOM_VALUES}: terminal.image must be ${EXPECTED_TERMINAL_IMAGE} (SHOWROOM-UPDATE-SPEC)"
  if ! nookbag_enabled_in "${SHOWROOM_VALUES}"; then
    err "${SHOWROOM_VALUES}: showroom.nookbag.enabled must be true (ZT UI shell for ui-config.yml split-screen)"
  fi
  grep -qF "nookbag-v0.4.0" "${SHOWROOM_VALUES}" \
    || err "${SHOWROOM_VALUES}: nookbag.bundleUrl must be nookbag-v0.4.0+ (ui-config tabs)"
fi

# --- root-app values (passed into ArgoCD Application) ---
if [[ -f "${ROOT_VALUES}" ]]; then
  has_line "${ROOT_VALUES}" "antoraPlaybook:[[:space:]]*[\"']?${EXPECTED_PLAYBOOK}[\"']?" \
    || err "${ROOT_VALUES}: components.showroom.content.antoraPlaybook must be ${EXPECTED_PLAYBOOK}"
  grep -qF "${EXPECTED_CONTENT_IMAGE}" "${ROOT_VALUES}" \
    || err "${ROOT_VALUES}: components.showroom.content.image must be ${EXPECTED_CONTENT_IMAGE}"
  if ! nookbag_enabled_in "${ROOT_VALUES}"; then
    err "${ROOT_VALUES}: components.showroom.nookbag.enabled must be true"
  fi
fi

# --- Required module sources (discoverable in learner UI) ---
for page in "${REQUIRED_MODULES[@]}"; do
  [[ -f "${PAGES_DIR}/${page}" ]] || err "missing lab page ${PAGES_DIR}/${page}"
done

# --- Helm render: userinfo + route + playbook env ---
if command -v helm >/dev/null 2>&1; then
  DEPLOYER_DOMAIN="${DEPLOYER_DOMAIN:-apps.ci.example.com}"
  render="$(mktemp)"
  root_render="$(mktemp)"
  cleanup() { rm -f "${render}" "${root_render}"; }
  trap cleanup EXIT

  if ! helm template "ci-showroom" "${SHOWROOM_CHART}" \
    --set "deployer.domain=${DEPLOYER_DOMAIN}" \
    --set "deployer.apiUrl=https://api.ci.example.com:6443" \
    >"${render}"; then
    err "helm template ${SHOWROOM_CHART} failed"
  else
    grep -q 'demo.redhat.com/userinfo:' "${render}" \
      || err "rendered Showroom manifests missing demo.redhat.com/userinfo label"
    grep -qE "showroom_url:[[:space:]]*\"https://showroom\\.${DEPLOYER_DOMAIN}\"" "${render}" \
      || err "rendered userinfo missing showroom_url https://showroom.${DEPLOYER_DOMAIN}"
    grep -qE "value:[[:space:]]*\"?${EXPECTED_PLAYBOOK}\"?" "${render}" \
      || err "Deployment must set ANTORA_* env to ${EXPECTED_PLAYBOOK}"
    grep -qE 'ZT_UI_ENABLED' "${render}" \
      || err "ZT_UI_ENABLED must be present when nookbag/ZT UI shell is enabled"
    grep -qE 'SHOWROOM_UI_CONFIG' "${render}" \
      || err "SHOWROOM_UI_CONFIG must be present for ui-config.yml split-screen"
    grep -q 'demo.redhat.com/application: "lightwell-tssc-workshop"' "${render}" \
      || err "rendered manifests must label demo.redhat.com/application: lightwell-tssc-workshop"
    ok "helm template assertions OK (domain=${DEPLOYER_DOMAIN})"
  fi

  if ! helm template "ci-root" charts/root-app \
    --set "deployer.domain=${DEPLOYER_DOMAIN}" \
    --set "components.showroom.enabled=true" \
    >"${root_render}"; then
    err "helm template charts/root-app failed"
  else
    grep -qE "antoraPlaybook:[[:space:]]*\"${EXPECTED_PLAYBOOK}\"" "${root_render}" \
      || err "root-app Application valuesObject missing antoraPlaybook: \"${EXPECTED_PLAYBOOK}\""
    if ! grep -A5 -E 'nookbag:' "${root_render}" | grep -qE 'enabled:[[:space:]]*true'; then
      err "root-app Application valuesObject must set nookbag.enabled: true"
    fi
    ok "root-app Showroom Application assertions OK"
  fi
else
  echo "showroom-check: WARN: helm not installed — skipped render assertions" >&2
fi

if [[ "${failed}" -ne 0 ]]; then
  echo "showroom-check: FAILED" >&2
  exit 1
fi

ok "OK"
exit 0
