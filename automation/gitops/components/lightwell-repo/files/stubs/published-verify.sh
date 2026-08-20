#!/usr/bin/env bash
set -euo pipefail
# V2-53 incomplete seed (1.1). Fill the pull spec and key URL placeholders;
# do not copy validate-docs or the worked example from the page. Check grades
# this ConfigMap, not only ~/ .
export HUMMINGBIRD_PUBLISHED='REPLACE_ME_HUMMINGBIRD_PULLSPEC'
cosign verify \
  --key REPLACE_ME_COSIGN_KEY \
  --insecure-ignore-tlog \
  "${HUMMINGBIRD_PUBLISHED}"
