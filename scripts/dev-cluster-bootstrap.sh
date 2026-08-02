#!/usr/bin/env bash
# Provision OpenShift GitOps (optional) + Argo Application for charts/root-app
# on an ephemeral RHDP OpenShift claim. Requires claim.env + oc login.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT}"

CLAIM_ENV="${CLAIM_ENV:-${ROOT}/dev-cluster/claim.env}"
CHART="${ROOT}/dev-cluster/helm"

if [[ ! -f "${CLAIM_ENV}" ]]; then
  echo "dev-cluster-bootstrap: missing ${CLAIM_ENV}" >&2
  echo "Copy dev-cluster/claim.env.example → claim.env and fill from the RHDP email." >&2
  exit 1
fi

if ! command -v helm >/dev/null 2>&1; then
  echo "dev-cluster-bootstrap: helm not found on PATH" >&2
  exit 1
fi

if ! command -v oc >/dev/null 2>&1; then
  echo "dev-cluster-bootstrap: oc not found on PATH" >&2
  exit 1
fi

set -a
# shellcheck disable=SC1090
source "${CLAIM_ENV}"
set +a

: "${API_URL:?API_URL required}"
: "${DEPLOYER_DOMAIN:?DEPLOYER_DOMAIN required}"

GIT_REPO="${GIT_REPO:-https://github.com/NA-FSI-Services/lightwell-tssc-workshop.git}"
GIT_REVISION="${GIT_REVISION:-main}"
ANTORA_PLAYBOOK="${ANTORA_PLAYBOOK:-site-ci.yml}"
BOOTSTRAP_RELEASE="${BOOTSTRAP_RELEASE:-lightwell-dev-bootstrap}"
BOOTSTRAP_NAMESPACE="${BOOTSTRAP_NAMESPACE:-openshift-gitops}"
INSTALL_GITOPS_OPERATOR="${INSTALL_GITOPS_OPERATOR:-true}"
WAIT_GITOPS_SECONDS="${WAIT_GITOPS_SECONDS:-600}"

if ! oc whoami >/dev/null 2>&1; then
  echo "dev-cluster-bootstrap: not logged in — run ./scripts/dev-cluster-login.sh first" >&2
  exit 1
fi

helm_common=(
  upgrade --install "${BOOTSTRAP_RELEASE}" "${CHART}"
  --namespace "${BOOTSTRAP_NAMESPACE}"
  --create-namespace
  --set "deployer.domain=${DEPLOYER_DOMAIN}"
  --set "deployer.apiUrl=${API_URL}"
  --set "gitops.repoUrl=${GIT_REPO}"
  --set "gitops.revision=${GIT_REVISION}"
  --set "showroom.antoraPlaybook=${ANTORA_PLAYBOOK}"
  --set "showroom.repoRef=${GIT_REVISION}"
)

if [[ "${INSTALL_GITOPS_OPERATOR}" == "true" ]]; then
  echo "dev-cluster-bootstrap: phase 1 — GitOps operator Subscription"
  helm "${helm_common[@]}" \
    --set gitopsOperator.enabled=true \
    --set application.enabled=false

  echo "dev-cluster-bootstrap: waiting for Application CRD (up to ${WAIT_GITOPS_SECONDS}s)"
  deadline=$((SECONDS + WAIT_GITOPS_SECONDS))
  until oc get crd applications.argoproj.io >/dev/null 2>&1; do
    if (( SECONDS >= deadline )); then
      echo "dev-cluster-bootstrap: timed out waiting for applications.argoproj.io" >&2
      echo "Check: oc -n openshift-gitops-operator get csv,sub,ip" >&2
      exit 1
    fi
    sleep 5
  done
  echo "dev-cluster-bootstrap: Application CRD present"
else
  echo "dev-cluster-bootstrap: skipping GitOps operator install (INSTALL_GITOPS_OPERATOR=false)"
fi

echo "dev-cluster-bootstrap: phase 2 — Argo Application for charts/root-app"
helm "${helm_common[@]}" \
  --set "gitopsOperator.enabled=${INSTALL_GITOPS_OPERATOR}" \
  --set application.enabled=true

echo "dev-cluster-bootstrap: Application status"
oc -n openshift-gitops get applications.argoproj.io lightwell-tssc-root -o wide 2>/dev/null \
  || echo "dev-cluster-bootstrap: WARN: Application not visible yet — wait for openshift-gitops namespace"

echo "dev-cluster-bootstrap: Showroom URL (after sync): https://showroom.${DEPLOYER_DOMAIN}/"
echo "dev-cluster-bootstrap: next steps"
echo "  1) ./scripts/dev-cluster-htpasswd.sh   # HTPasswd IdP admin (claim.env HTPASSWD_*)"
echo "  2) Set OC_LOGIN_MODE=password in claim.env, then ./scripts/dev-cluster-login.sh"
echo "  3) Enable components by sync wave (lightwellRepo before Module 1 exercises)"
echo "  4) Walk https://showroom.${DEPLOYER_DOMAIN}/modules/module-01-overview.html"
echo "dev-cluster-bootstrap: OK"
