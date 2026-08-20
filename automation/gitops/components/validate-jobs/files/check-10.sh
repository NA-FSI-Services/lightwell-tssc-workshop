#!/usr/bin/env bash
# 4.3 — build-egress is not allow-all; DNS + registry + Nexus; not copied to stage.
set -euo pipefail
ns="$(build_ns)"
stage="$(stage_ns)"
yaml="$(oc -n "$ns" get networkpolicy build-egress -o yaml 2>/dev/null \
  || fail "NetworkPolicy ${ns}/build-egress is missing.")"
to="$(oc -n "$ns" get networkpolicy build-egress -o jsonpath='{.spec.egress[*].to}' 2>/dev/null || true)"
[[ -n "$to" ]] || fail "NetworkPolicy ${ns}/build-egress is still allow-all egress. Tighten to DNS + registry + Nexus."
printf '%s\n' "$yaml" | grep -qE 'port: 53|port: 5353' \
  || fail "build-egress must allow DNS (UDP 53 or 5353)."
printf '%s\n' "$yaml" | grep -q 'image-registry' \
  || fail "build-egress must allow the in-cluster image registry."
printf '%s\n' "$yaml" | grep -qE 'lightwell-repo|nexus' \
  || fail "build-egress must allow in-cluster Nexus (lightwell-repo)."
printf '%s\n' "$yaml" | grep -q 'stackrox' \
  || fail "build-egress must allow namespace stackrox (Central pod port 8443) so ACS can run after 4.3."
printf '%s\n' "$yaml" | grep -qE 'port: 8443' \
  || fail "build-egress must allow TCP 8443 to stackrox (Central Service 443 maps to pod 8443)."
printf '%s\n' "$yaml" | grep -q 'trusted-artifact-signer' \
  || fail "build-egress must allow trusted-artifact-signer (TUF/Fulcio/Rekor pod ports) so 5.1 can sign."
deny_contains "build-egress" "$yaml" "8.8.8.8"
if oc -n "$stage" get networkpolicy build-egress >/dev/null 2>&1; then
  fail "Do not copy build-egress onto ${stage}. Tighten it only in ${ns}."
fi
oc -n "$stage" get networkpolicy app-operate >/dev/null \
  || fail "NetworkPolicy ${stage}/app-operate (operate seed) is missing."
report_require_token np_scope build-ns
pass "build-egress is hermetic in ${ns} and was not copied to staging."
