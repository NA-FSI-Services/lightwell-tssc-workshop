#!/usr/bin/env bash
# 7.1 — promoted digest committed + SBOM TaskRun. TPA UI ingest is not visible without secrets.
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
pass "Promoted digest is in the prod GitOps remote and the syft SBOM TaskRun succeeded (TPA UI is Showroom)."
