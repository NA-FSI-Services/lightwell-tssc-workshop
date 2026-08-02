#!/usr/bin/env bash
# Provision OpenShift GitOps (optional) + Argo Application for charts/root-app
# on an ephemeral RHDP OpenShift claim. Requires claim.env + oc login.
#
# Hardening learned from bare OCP-on-AWS claims:
#   - Scale workers when MachineSets ship at 0 (single-node claims starve GitOps)
#   - Grant ArgoCD application-controller cluster-admin
#   - Enable showroom + lightwellRepo for Module 1 ConfigMap exercises
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
WAIT_ARGOCD_SECONDS="${WAIT_ARGOCD_SECONDS:-600}"
ENABLE_LIGHTWELL_REPO="${ENABLE_LIGHTWELL_REPO:-true}"
SHOWROOM_LAB_CLUSTER_ACCESS="${SHOWROOM_LAB_CLUSTER_ACCESS:-true}"
SCALE_WORKERS="${SCALE_WORKERS:-true}"
ARGOCD_GRANT_CLUSTER_ADMIN="${ARGOCD_GRANT_CLUSTER_ADMIN:-true}"

if ! oc whoami >/dev/null 2>&1; then
  echo "dev-cluster-bootstrap: not logged in — run ./scripts/dev-cluster-login.sh first" >&2
  exit 1
fi

# --- Phase 0: capacity (claim MachineSets often start at replicas=0) ---
if [[ "${SCALE_WORKERS}" == "true" ]]; then
  echo "dev-cluster-bootstrap: phase 0 — scale workers if needed"
  CLAIM_ENV="${CLAIM_ENV}" "${ROOT}/scripts/dev-cluster-scale-workers.sh"
else
  echo "dev-cluster-bootstrap: phase 0 — SCALE_WORKERS=false, skipping MachineSet scale"
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
  --set "showroom.labClusterAccess=${SHOWROOM_LAB_CLUSTER_ACCESS}"
  --set "lightwellRepo.enabled=${ENABLE_LIGHTWELL_REPO}"
  --set "argocd.grantClusterAdmin=${ARGOCD_GRANT_CLUSTER_ADMIN}"
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
      echo "If pods are Pending: ensure workers are Ready (./scripts/dev-cluster-scale-workers.sh)" >&2
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

echo "dev-cluster-bootstrap: waiting for Argo CD controller/server (up to ${WAIT_ARGOCD_SECONDS}s)"
deadline=$((SECONDS + WAIT_ARGOCD_SECONDS))
while true; do
  server_ready="$(oc -n openshift-gitops get deploy openshift-gitops-server -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo 0)"
  ctrl_ready="$(oc -n openshift-gitops get statefulset openshift-gitops-application-controller -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo 0)"
  server_ready="${server_ready:-0}"
  ctrl_ready="${ctrl_ready:-0}"
  if [[ "${server_ready}" -ge 1 && "${ctrl_ready}" -ge 1 ]]; then
    echo "dev-cluster-bootstrap: Argo CD ready (server=${server_ready} controller=${ctrl_ready})"
    break
  fi
  if (( SECONDS >= deadline )); then
    echo "dev-cluster-bootstrap: WARN: timed out waiting for Argo CD pods — continuing" >&2
    oc -n openshift-gitops get pods -o wide 2>/dev/null || true
    break
  fi
  sleep 10
done

if [[ "${ARGOCD_GRANT_CLUSTER_ADMIN}" == "true" ]]; then
  echo "dev-cluster-bootstrap: ensuring Argo CD application-controller cluster-admin"
  # Helm ClusterRoleBinding may apply before the SA exists; oc adm is idempotent.
  oc adm policy add-cluster-role-to-user cluster-admin \
    -z openshift-gitops-argocd-application-controller \
    -n openshift-gitops >/dev/null
fi

echo "dev-cluster-bootstrap: Application status"
oc -n openshift-gitops get applications.argoproj.io lightwell-tssc-root -o wide 2>/dev/null \
  || echo "dev-cluster-bootstrap: WARN: Application not visible yet — wait for openshift-gitops namespace"

echo "dev-cluster-bootstrap: Showroom URL (after sync): https://showroom.${DEPLOYER_DOMAIN}/"
echo "dev-cluster-bootstrap: Module 1: https://showroom.${DEPLOYER_DOMAIN}/modules/module-01-overview.html"
echo "dev-cluster-bootstrap: next steps"
echo "  1) ./scripts/dev-cluster-htpasswd.sh   # HTPasswd IdP admin (claim.env HTPASSWD_*)"
echo "  2) Set OC_LOGIN_MODE=password in claim.env, then ./scripts/dev-cluster-login.sh"
echo "  3) Wait for lightwell-tssc-root-showroom + lightwell-tssc-root-lightwell-repo Healthy"
echo "  4) Smoke: oc -n showroom exec deploy/showroom -c terminal -- oc -n lightwell-repo get cm lightwell-channels"
echo "dev-cluster-bootstrap: OK"
