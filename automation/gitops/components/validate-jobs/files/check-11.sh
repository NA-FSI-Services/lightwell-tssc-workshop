#!/usr/bin/env bash
# 4.4 — app ImageStream exists; syft-sbom-rhtpa Succeeded; known-bad leftover remains.
set -euo pipefail
org="$(learner_org)"
repo="$(learner_app_repo)"
ns="$(build_ns)"
gitea_repo_ok "$org" "$repo"
oc -n "$ns" get imagestream spring-boot-lw-poc >/dev/null \
  || fail "ImageStream ${ns}/spring-boot-lw-poc is missing. Run the BuildConfig pipeline."
digest="$(oc -n "$ns" get istag spring-boot-lw-poc:latest \
  -o jsonpath='{.image.dockerImageReference}' 2>/dev/null || true)"
[[ -n "$digest" ]] || fail "ImageStreamTag ${ns}/spring-boot-lw-poc:latest has no digest yet."
taskrun_succeeded "$ns" syft-sbom-rhtpa
bad="$(gitea_raw "$org" "$repo" Dockerfile.known-bad)"
require_contains "Dockerfile.known-bad" "$bad" "docker.io"
report_require_token image_builder buildconfig build-config
pass "BuildConfig image and syft SBOM exist; Dockerfile.known-bad is still present."
