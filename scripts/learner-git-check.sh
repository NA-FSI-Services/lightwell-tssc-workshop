#!/usr/bin/env bash
# Enforce Gitea learner-Git decision (#120) in learner-facing paths.
# Usage: scripts/learner-git-check.sh
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT}"

failed=0
err() { echo "learner-git-check: ERROR: $*" >&2; failed=1; }
ok() { echo "learner-git-check: $*"; }

# Paths students / Showroom / seeded lab trees can see
SCAN_PATHS=(
  docs/modules
  charts/components/gitea/files/seed/overlay
  charts/components/gitea/files/seed/overlay-gitops
  charts/components/gitea/files/seed/repo
  charts/components/rhdh/files/skeletons
  charts/components/rhdh/files/catalog
)

# Hardcoded per-user remotes in seeded content (init must stay username-agnostic)
HARDCODE_PATTERNS=(
  'lw-user1'
  'gitea\.[^/]+/user1/'
  '/user1/spring-boot-lw-poc'
)

# GitHub monorepo as a clone/repo-url target in learner-facing files
# Allow lines that clearly forbid cloning (Do not / never / IMPORTANT).
GITHUB_MONOREPO='github\.com/NA-FSI-Services/lightwell-tssc-workshop\.git'

for p in "${HARDCODE_PATTERNS[@]}"; do
  hits="$(rg -n --glob '!**/README.md' -e "$p" "${SCAN_PATHS[@]}" 2>/dev/null || true)"
  if [[ -n "${hits}" ]]; then
    err "hardcoded learner username/remote pattern /$p/:"
    echo "${hits}" >&2
  fi
done

# GitHub .git URL in modules / overlays / skeletons / catalog (except ban warnings)
while IFS= read -r line; do
  [[ -z "${line}" ]] && continue
  file="${line%%:*}"
  rest="${line#*:}"
  linenum="${rest%%:*}"
  text="${rest#*:}"
  if echo "${text}" | grep -qiE 'do \*not\*|do not|never|IMPORTANT|Hard ban|not clone'; then
    continue
  fi
  # Catalog/skeleton comments pointing at operator seed are still discouraged if they are clone URLs
  err "${file}:${linenum}: GitHub monorepo URL in learner-facing path (use workshop-templates / student_repo_url):"
  echo "  ${text}" >&2
done < <(rg -n -e "${GITHUB_MONOREPO}" "${SCAN_PATHS[@]}" 2>/dev/null || true)

# PipelineRun overlays must use placeholder
for f in \
  charts/components/gitea/files/seed/overlay/tekton/pipelinerun.yaml \
  charts/components/rhdh/files/skeletons/lightwell-java-service/.tekton/pipelinerun.yaml
do
  [[ -f "$f" ]] || continue
  if ! grep -q 'STUDENT_REPO_URL_PLACEHOLDER' "$f"; then
    err "${f}: repo-url must use STUDENT_REPO_URL_PLACEHOLDER (lab substitutes student_repo_url)"
  fi
done

# Software Template must not publish to GitHub
if [[ -f charts/components/rhdh/files/catalog/lightwell-java-service.yaml ]]; then
  if grep -q 'publish:github' charts/components/rhdh/files/catalog/lightwell-java-service.yaml; then
    err "lightwell-java-service.yaml: use publish:gitea, not publish:github"
  fi
  if grep -qE 'owner=user1|repo=.*user1' charts/components/rhdh/files/catalog/lightwell-java-service.yaml; then
    err "lightwell-java-service.yaml: do not hardcode user1 owner/repo"
  fi
fi

if [[ "${failed}" -ne 0 ]]; then
  echo "learner-git-check: FAILED" >&2
  exit 1
fi
ok "OK"
