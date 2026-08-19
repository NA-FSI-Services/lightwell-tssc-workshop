#!/usr/bin/env bash
# 7.2 — blast-radius tokens + ACS fail-on-skipped true; TaskRun not skipped.
set -euo pipefail
org="$(learner_org)"
repo="$(learner_app_repo)"
ns="$(build_ns)"
body="$(cm_get "$REPO_NS" stub-18-blast-radius blast-radius.txt)"
[[ -n "$body" ]] || fail "ConfigMap ${REPO_NS}/stub-18-blast-radius key blast-radius.txt is empty."
deny_placeholder "stub-18-blast-radius" "$body"
deny_contains "stub-18-blast-radius" "$body" "LW-DEMO-0001"
require_contains "stub-18-blast-radius" "$body" "LW-DEMO-0002"
require_contains "stub-18-blast-radius" "$body" "3.14.0.rhlw-00001"
require_contains "stub-18-blast-radius" "$body" "via-lightwell-pin"
gitea_repo_ok "$org" "$repo"
pl="$(gitea_raw "$org" "$repo" .tekton/pipeline.yaml)"
# Seed is value: "false". Learner must set true on acs-image-check.
printf '%s\n' "$pl" | grep -A6 'name: acs-image-check' | grep -q 'fail-on-skipped' \
  || fail "${org}/${repo} .tekton/pipeline.yaml acs-image-check is missing fail-on-skipped."
acs_block="$(printf '%s\n' "$pl" | awk '/name: acs-image-check/,/name: syft-sbom-rhtpa/')"
require_contains "acs-image-check params" "$acs_block" 'value: "true"'
deny_contains "acs-image-check params" "$acs_block" 'value: "false"'
results="$(oc -n "$ns" get taskrun -l tekton.dev/pipelineTask=acs-image-check \
  -o jsonpath='{range .items[*]}{.status.taskResults[?(@.name=="check-status")].value}{"\n"}{end}' 2>/dev/null || true)"
[[ -n "$results" ]] || fail "No acs-image-check TaskRun in ${ns}. Re-run the pipeline after setting fail-on-skipped true."
latest="$(printf '%s\n' "$results" | grep -v '^$' | tail -1)"
[[ "$latest" == "passed" || "$latest" == "failed" ]] \
  || fail "Latest acs-image-check check-status is '${latest:-empty}' (must be passed or failed, not skipped)."
csaf="$(cm_get trusted-profile-analyzer rhtpa-ingestion-info live_csaf_gate)"
[[ "$csaf" == "false" ]] || fail "live_csaf_gate must stay false."
pass "Blast-radius tokens are scored and ACS image check is on (not skipped)."
