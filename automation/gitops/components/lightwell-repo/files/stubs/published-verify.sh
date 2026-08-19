#!/usr/bin/env bash
set -euo pipefail
# V2-53 incomplete seed (1.1). Replace REPLACE_ME_*; do not copy validate-docs
# or the ubi-minimal worked example. Check grades this ConfigMap, not only ~/ .
export HUMMINGBIRD_PUBLISHED='REPLACE_ME_HUMMINGBIRD_PULLSPEC'
cosign verify \
  --key REPLACE_ME_COSIGN_KEY \
  --insecure-ignore-tlog \
  "${HUMMINGBIRD_PUBLISHED}"
