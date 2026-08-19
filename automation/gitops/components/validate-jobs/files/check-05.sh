#!/usr/bin/env bash
# 3.1 — learner Gitea remote exists and is not the template org.
set -euo pipefail
org="$(learner_org)"
repo="$(learner_app_repo)"
template_url="$(userinfo "$GITEA_NS" "$GITEA_USERINFO" template_app_repo_url)"
student_url="$(userinfo "$GITEA_NS" "$GITEA_USERINFO" student_repo_url)"
[[ "$student_url" != "$template_url" ]] || fail "student_repo_url still points at the template org."
case "$student_url" in
  *workshop-templates*) fail "student_repo_url must be lw-student, not workshop-templates." ;;
esac
gitea_repo_ok "$org" "$repo"
pom="$(gitea_raw "$org" "$repo" pom.xml)"
require_contains "${org}/${repo} pom.xml" "$pom" "<project"
pass "Learner remote ${org}/${repo} exists with pom.xml at the repository root."
