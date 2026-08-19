#!/usr/bin/env bash
# 5.1 — keyless sign TaskRun Succeeded; PipelineRun placeholders gone in git.
set -euo pipefail
org="$(learner_org)"
repo="$(learner_app_repo)"
ns="$(build_ns)"
gitea_repo_ok "$org" "$repo"
pr="$(gitea_raw "$org" "$repo" .tekton/pipelinerun.yaml)"
deny_contains "${org}/${repo} .tekton/pipelinerun.yaml" "$pr" "STUDENT_REPO_URL_PLACEHOLDER"
deny_contains "${org}/${repo} .tekton/pipelinerun.yaml" "$pr" "apps.<domain>"
deny_contains "${org}/${repo} .tekton/pipelinerun.yaml" "$pr" "<lab-namespace>"
taskrun_succeeded "$ns" cosign-sign-keyless
digest="$(oc -n "$ns" get istag spring-boot-lw-poc:latest \
  -o jsonpath='{.image.dockerImageReference}' 2>/dev/null || true)"
[[ "$digest" == *@sha256:* || "$digest" == *sha256:* ]] \
  || fail "ImageStreamTag ${ns}/spring-boot-lw-poc:latest has no sha256 digest to verify."
report_require_token what_you_signed app-digest
pass "cosign-sign-keyless Succeeded on the learner app digest."
