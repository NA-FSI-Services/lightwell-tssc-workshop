#!/usr/bin/env bash
# 5.3 — app digest exists for key-based sign. Showroom ~/lab-trust is not visible here.
set -euo pipefail
ns="$(build_ns)"
taskrun_succeeded "$ns" cosign-sign-keyless
digest="$(oc -n "$ns" get istag spring-boot-lw-poc:latest \
  -o jsonpath='{.image.dockerImageReference}' 2>/dev/null || true)"
[[ "$digest" == *@sha256:* || "$digest" == *sha256:* ]] \
  || fail "ImageStreamTag ${ns}/spring-boot-lw-poc:latest has no sha256 digest. Finish 5.1 first."
pass "App digest is present for key-based verify (Showroom ~/lab-trust is not graded by this Job)."
