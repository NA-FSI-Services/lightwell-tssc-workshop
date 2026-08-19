#!/usr/bin/env bash
# 3.2 — committed Dockerfile runtime FROM dest + digest; default pin; pins still stale.
set -euo pipefail
org="$(learner_org)"
repo="$(learner_app_repo)"
gitea_repo_ok "$org" "$repo"
df="$(gitea_raw "$org" "$repo" Dockerfile)"
dest="$(userinfo "$REPO_NS" "$REPO_USERINFO" dest_registry_host)"
require_contains "${org}/${repo} Dockerfile" "$df" "$dest"
require_contains "${org}/${repo} Dockerfile" "$df" "sha256:"
deny_contains "${org}/${repo} Dockerfile runtime" "$df" "ubi9/openjdk-21-runtime"
deny_contains "${org}/${repo} Dockerfile" "$df" "eclipse-temurin"
pom="$(gitea_raw "$org" "$repo" pom.xml)"
require_contains "${org}/${repo} pom.xml" "$pom" "<commons.lang3.version>3.14.0.rhlw-00001</commons.lang3.version>"
pass "Learner Dockerfile runtime FROM is dest+digest and the default pom pin is the scored GAV."
