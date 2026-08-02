#!/usr/bin/env bash
# Scale OpenShift MachineSets on ephemeral RHDP claims that ship with workers=0.
# Undersized single-node (master-only) claims cannot schedule GitOps / Showroom / Nexus.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLAIM_ENV="${CLAIM_ENV:-${ROOT}/dev-cluster/claim.env}"

if [[ -f "${CLAIM_ENV}" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "${CLAIM_ENV}"
  set +a
fi

WORKER_REPLICAS="${WORKER_REPLICAS:-2}"
WAIT_WORKERS_SECONDS="${WAIT_WORKERS_SECONDS:-900}"
SCALE_WORKERS="${SCALE_WORKERS:-true}"

if [[ "${SCALE_WORKERS}" != "true" ]]; then
  echo "dev-cluster-scale-workers: SCALE_WORKERS=${SCALE_WORKERS} — skipping"
  exit 0
fi

if ! command -v oc >/dev/null 2>&1; then
  echo "dev-cluster-scale-workers: oc not found on PATH" >&2
  exit 1
fi

if ! oc whoami >/dev/null 2>&1; then
  echo "dev-cluster-scale-workers: not logged in — run ./scripts/dev-cluster-login.sh first" >&2
  exit 1
fi

if ! oc get machineset -n openshift-machine-api >/dev/null 2>&1; then
  echo "dev-cluster-scale-workers: WARN: Machine API unavailable — scale workers via AWS console if needed"
  exit 0
fi

ms_jsonpath='{range .items[*]}{.metadata.name}{" "}{.spec.replicas}{"\n"}{end}'
ms_out="$(oc -n openshift-machine-api get machineset -o jsonpath="${ms_jsonpath}" 2>/dev/null || true)"
if [[ -z "${ms_out}" ]]; then
  echo "dev-cluster-scale-workers: WARN: no MachineSets found — skipping"
  exit 0
fi

total=0
zero_ms=""
first_ms=""
while read -r name replicas; do
  [[ -z "${name}" ]] && continue
  replicas="${replicas:-0}"
  [[ -z "${first_ms}" ]] && first_ms="${name}"
  total=$((total + replicas))
  if [[ "${replicas}" -eq 0 && -z "${zero_ms}" ]]; then
    zero_ms="${name}"
  fi
done <<< "${ms_out}"

echo "dev-cluster-scale-workers: desired worker replicas across MachineSets=${total} (target=${WORKER_REPLICAS})"

if (( total >= WORKER_REPLICAS )); then
  echo "dev-cluster-scale-workers: already at or above target — no scale"
else
  need=$((WORKER_REPLICAS - total))
  target_ms="${zero_ms:-${first_ms}}"
  current="$(oc -n openshift-machine-api get machineset "${target_ms}" -o jsonpath='{.spec.replicas}')"
  current="${current:-0}"
  new_replicas=$((current + need))
  echo "dev-cluster-scale-workers: scaling machineset/${target_ms} ${current} → ${new_replicas}"
  oc -n openshift-machine-api scale "machineset/${target_ms}" --replicas="${new_replicas}"
fi

# Wait until Ready node count reaches master + workers (masters often also have worker role).
min_nodes=$((1 + WORKER_REPLICAS))
echo "dev-cluster-scale-workers: waiting for >= ${min_nodes} Ready nodes (up to ${WAIT_WORKERS_SECONDS}s)"
deadline=$((SECONDS + WAIT_WORKERS_SECONDS))
while true; do
  ready="$(oc get nodes --no-headers 2>/dev/null | awk '$2=="Ready"{c++} END{print c+0}')"
  echo "dev-cluster-scale-workers: Ready nodes=${ready}"
  if (( ready >= min_nodes )); then
    break
  fi
  if (( SECONDS >= deadline )); then
    echo "dev-cluster-scale-workers: WARN: timed out with Ready nodes=${ready} (wanted ${min_nodes})" >&2
    oc get nodes -o wide || true
    oc -n openshift-machine-api get machineset,machines || true
    exit 0
  fi
  sleep 15
done

oc get nodes -o wide
echo "dev-cluster-scale-workers: OK"
