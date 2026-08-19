#!/usr/bin/env bash
# 1.2 — ImageSet filled and oc-mirror-learner Completed (cosign is Showroom).
set -euo pipefail
body="$(cm_get "$REPO_NS" imageset-configuration imageset-config.yaml)"
[[ -n "$body" ]] || fail "ConfigMap ${REPO_NS}/imageset-configuration is empty."
deny_placeholder "imageset-configuration" "$body"
deny_contains "imageset-configuration" "$body" "ubi-minimal"
pin="$(userinfo "$REPO_NS" "$REPO_USERINFO" hummingbird_source_pullspec)"
require_contains "imageset-configuration" "$body" "$pin"
job_succeeded "$REPO_NS" oc-mirror-learner
report_require_token learner_runs_mirror learner-mirror
pass "ImageSet is the Hummingbird pin and Job oc-mirror-learner Completed."
