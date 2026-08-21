#!/usr/bin/env bash
# 6.1 — TrustPolicy filled+enforce; ImagePolicy live on stage and prod; stage Healthy.
set -euo pipefail
org="$(learner_org)"
gitops="$(learner_gitops_repo)"
stage="$(stage_ns)"
prod="$(prod_ns)"
argo="$(userinfo "$GITEA_NS" "$GITEA_USERINFO" student_argocd_app)"
policy="$(userinfo tssc-admission demo-userinfo-admission policy_name)"
gitea_repo_ok "$org" "$gitops"
tp="$(gitea_raw "$org" "$gitops" admission/trust-policy.yaml)"
deny_placeholder "${org}/${gitops} admission/trust-policy.yaml" "$tp"
require_contains "${org}/${gitops} TrustPolicy" "$tp" "enforce: true"
deny_contains "${org}/${gitops} TrustPolicy" "$tp" "enforce: false"
deny_contains "${org}/${gitops} TrustPolicy" "$tp" "example.invalid"
oc -n "$stage" get imagepolicy.config.openshift.io "$policy" >/dev/null 2>&1 \
  || fail "ImagePolicy ${stage}/${policy} is missing. Wait for CronJob trust-policy-apply."
oc -n "$prod" get imagepolicy.config.openshift.io "$policy" >/dev/null 2>&1 \
  || fail "ImagePolicy ${prod}/${policy} is missing. Wait for CronJob trust-policy-apply."
health="$(oc -n openshift-gitops get applications.argoproj.io "$argo" \
  -o jsonpath='{.status.health.status}' 2>/dev/null || true)"
[[ "$health" == "Healthy" ]] || fail "Application ${argo} health is '${health:-missing}', not Healthy."
replicas="$(oc -n "$stage" get deploy spring-boot-lw-poc -o jsonpath='{.spec.replicas}' 2>/dev/null || true)"
[[ "$replicas" == "1" ]] || fail "Deployment ${stage}/spring-boot-lw-poc replicas is '${replicas:-missing}', not 1. Push digest + replicas: 1 and hard-refresh Argo (Healthy at 0 replicas is the seed)."
report_require_token live_api imagepolicy image-policy
pass "TrustPolicy is enforced, ImagePolicy is live on stage and prod, and ${argo} is Healthy."
