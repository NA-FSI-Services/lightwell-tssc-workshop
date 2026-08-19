#!/usr/bin/env bash
# 4.2 — prefetch-dependencies wired before openshift-build; Central gone; mvn -o.
set -euo pipefail
org="$(learner_org)"
repo="$(learner_app_repo)"
ns="$(build_ns)"
gitea_repo_ok "$org" "$repo"
git_pl="$(gitea_raw "$org" "$repo" .tekton/pipeline.yaml)"
task_before "$git_pl" prefetch-dependencies openshift-build "${org}/${repo} .tekton/pipeline.yaml"
live="$(pipeline_yaml "$ns" spring-boot-lw-poc-build-sign)"
task_before "$live" prefetch-dependencies openshift-build "Pipeline ${ns}/spring-boot-lw-poc-build-sign"
settings="$(gitea_raw "$org" "$repo" settings.xml)"
deny_contains "${org}/${repo} settings.xml" "$settings" "repo.maven.apache.org"
df="$(gitea_raw "$org" "$repo" Dockerfile)"
require_contains "${org}/${repo} Dockerfile" "$df" "mvn"
require_contains "${org}/${repo} Dockerfile" "$df" "-o"
pass "prefetch-dependencies is before openshift-build and Maven is offline."
