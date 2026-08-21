#!/usr/bin/env bash
# 7.1 — promoted digest + syft TaskRun + TPA filesystem PVC/Route (ingest UI still Showroom).
set -euo pipefail
org="$(learner_org)"
prod_repo="$(learner_prod_gitops_repo)"
ns="$(build_ns)"
gitea_repo_ok "$org" "$prod_repo"
values="$(gitea_raw "$org" "$prod_repo" values.yaml)"
deny_contains "${org}/${prod_repo} values.yaml" "$values" "REPLACE_ME_PROD_DIGEST"
require_contains "${org}/${prod_repo} values.yaml" "$values" "sha256:"
taskrun_succeeded "$ns" syft-sbom-rhtpa
csaf="$(cm_get trusted-profile-analyzer rhtpa-ingestion-info live_csaf_gate)"
[[ "$csaf" == "false" ]] || fail "live_csaf_gate must stay false (do not enable the Red Hat CSAF importer)."
pvc="$(oc -n trusted-profile-analyzer get pvc storage -o jsonpath='{.status.phase}' 2>/dev/null || true)"
[[ "$pvc" == "Bound" ]] || fail "PVC trusted-profile-analyzer/storage is '${pvc:-missing}' (migrate-db needs claimName storage). TPA will 503 until it is Bound."
oc -n trusted-profile-analyzer get route -o jsonpath='{range .items[*]}{.spec.host}{"\n"}{end}' 2>/dev/null \
  | grep -q 'server-trusted-profile-analyzer' \
  || fail "TPA server Route is missing in trusted-profile-analyzer. migrate-db / filesystem PVC must complete before 7.1 ingest."
report_require_token sor_object promoted-digest
pass "Promoted digest is in the prod GitOps remote, syft succeeded, and TPA storage/Route are up."
