# charts/components/validate-jobs — in-cluster Checks (V2-51)

Classic Showroom, honor system, **no Solve**, no `runtime-automation/`.
Provision does **not** create Job instances and does **not** pass any track.

## What it deploys

| Resource | Purpose |
|----------|---------|
| Namespace `lw-poc-validate` | Jobs, helper, reports, userinfo |
| ServiceAccount `validate-jobs` | Read-only inspect SA used **inside** the Job |
| ClusterRole `validate-jobs` | get/list on lab objects (no secrets, no create) |
| ConfigMap `validate-scripts` | Shared `helper.sh` + stub `check.sh` |
| ConfigMap `validate-job-templates` | One `job-NN.yaml` per gated module (learner `oc create`) |
| ConfigMap `report-<id>-<slug>` (×18) | Learner-owned short-answer report; seed `status: REPLACE_ME` |
| ConfigMap `demo-userinfo-validate` | Rerun example, Job/report names |
| ConfigMap `validate-docs` | Worked examples that are **not** paste-identical |

Do **not** apply a passing Check at provision. Stubs always `CHECK FAILED` with a
teaching message until V2-54 fills cluster/git state. Quiz keys/tokens are V2-59.

## Learner rerun (unlimited)

```bash
oc -n lw-poc-validate delete job validate-01-hummingbird-verify --ignore-not-found
oc -n lw-poc-validate get configmap validate-job-templates \
  -o jsonpath='{.data.job-01\.yaml}' | oc create -f -
oc -n lw-poc-validate logs -f job/validate-01-hummingbird-verify
```

Same pattern as oc-mirror: templates live in a ConfigMap; the Job is not a Helm
object. `activeDeadlineSeconds: 60`. No attempt quota.

## Reports

One ConfigMap per gated module in `lw-poc-validate`. Learners `oc edit` keys.
The App-of-Apps `ignoreDifferences` `/data` so Argo selfHeal does not revert
those edits. Do not copy `example-report.yaml`.

## Sync waves (inside this chart)

| Wave | Resources |
|------|-----------|
| `0` | Namespace |
| `1` | RBAC + scripts |
| `2` | Reports + Job templates |
| `3` | userinfo + docs |

Root App-of-Apps places this chart at sync wave **`45`** (after sample apps,
before Showroom).

## Values of interest

| Key | Default | Notes |
|-----|---------|-------|
| `validateJobs.enabled` | `true` | Chart gate |
| `validateJobs.namespace` | `lw-poc-validate` | Not `lw-poc-build` |
| `job.image` | `openshift4/ose-cli:latest` | `oc` + bash |
| `job.activeDeadlineSeconds` | `60` | Plan budget |

## Local validation

```bash
helm lint automation/gitops/components/validate-jobs
helm template validate-jobs automation/gitops/components/validate-jobs \
  --set deployer.domain=apps.cluster.example.com
```

## Enable from root-app

```bash
helm template lightwell automation/gitops/bootstrap-infra \
  --set components.validateJobs.enabled=true \
  --set deployer.domain=apps.cluster.example.com
```

Keep `components.validateJobs.enabled: false` in committed root values until
the catalog stack is ready to sync this chart.

## Related

- [V2-51](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/33)
- Track checks: [V2-54](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/36)
- Report schema: [V2-59](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/40)
- How to run (content): V2-55 (not this chart)
