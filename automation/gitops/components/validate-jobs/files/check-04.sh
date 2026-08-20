#!/usr/bin/env bash
# 2.2 — default pom property is the scored .rhlw pin (not spring-core).
set -euo pipefail
body="$(cm_get "$REPO_NS" stub-04-remediated-pin pom.xml)"
[[ -n "$body" ]] || fail "ConfigMap ${REPO_NS}/stub-04-remediated-pin key pom.xml is empty."
deny_contains "stub-04-remediated-pin" "$body" "<commons.lang3.version>3.14.0</commons.lang3.version>"
deny_contains "stub-04-remediated-pin" "$body" "<commons.lang3.version>3.18.0</commons.lang3.version>"
deny_contains "stub-04-remediated-pin" "$body" "5.3.18.rhlw-00003"
require_contains "stub-04-remediated-pin" "$body" "<commons.lang3.version>3.14.0.rhlw-00001</commons.lang3.version>"
report_require_token pin_kind exact-version
pass "Default commons.lang3.version is 3.14.0.rhlw-00001."
