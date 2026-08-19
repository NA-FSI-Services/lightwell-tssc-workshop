#!/usr/bin/env bash
# 5.2 — tightened Conforma copy in build ns; task after sign; not the seed.
set -euo pipefail
org="$(learner_org)"
repo="$(learner_app_repo)"
ns="$(build_ns)"
gitea_repo_ok "$org" "$repo"
skip="$(cm_get "$ns" conforma-policy skip-image-sig-check)"
[[ "$skip" == "false" ]] || fail "ConfigMap ${ns}/conforma-policy skip-image-sig-check must be false (copy and tighten; do not edit lightwell-tasks)."
ident="$(cm_get "$ns" conforma-policy certificate-identity-regexp)"
[[ -n "$ident" ]] || fail "ConfigMap ${ns}/conforma-policy is missing certificate-identity-regexp."
[[ "$ident" != ".*" ]] || fail "certificate-identity-regexp is still '.*'. Use the pipeline SA identity."
deny_contains "${ns}/conforma-policy identity" "$ident" "example.invalid"
cve="$(cm_get "$ns" conforma-policy data.yaml)"
deny_contains "${ns}/conforma-policy data.yaml" "$cve" "restrict_max_cve_score: 999"
git_pl="$(gitea_raw "$org" "$repo" .tekton/pipeline.yaml)"
task_before "$git_pl" cosign-sign-keyless conforma-policy "${org}/${repo} .tekton/pipeline.yaml"
live="$(pipeline_yaml "$ns" spring-boot-lw-poc-build-sign)"
task_before "$live" cosign-sign-keyless conforma-policy "Pipeline ${ns}/spring-boot-lw-poc-build-sign"
printf '%s\n' "$live" | grep -A3 'policy-namespace' | grep -q "$ns" \
  || fail "conforma-policy policy-namespace must be ${ns} (the tightened copy), not lightwell-tasks."
pass "Conforma copy in ${ns} is tightened and runs after cosign-sign-keyless."
