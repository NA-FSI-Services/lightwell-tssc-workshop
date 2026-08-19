#!/usr/bin/env bash
# 2.1 — Maven settings ConfigMap points at in-cluster Nexus.
set -euo pipefail
body="$(cm_get "$REPO_NS" stub-03-enterprise-proxy settings.xml)"
[[ -n "$body" ]] || fail "ConfigMap ${REPO_NS}/stub-03-enterprise-proxy key settings.xml is empty."
deny_placeholder "stub-03-enterprise-proxy" "$body"
deny_contains "stub-03-enterprise-proxy" "$body" "example.invalid"
nexus="$(userinfo "$REPO_NS" "$REPO_USERINFO" nexus_url)"
require_contains "stub-03-enterprise-proxy" "$body" "$nexus"
validated="$(userinfo "$REPO_NS" "$REPO_USERINFO" channel_validated)"
require_contains "stub-03-enterprise-proxy" "$body" "$validated"
pass "settings.xml uses in-cluster Nexus Validated/Remediated, not the worked example."
