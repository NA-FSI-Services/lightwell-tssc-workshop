# qa-automation — V2-22 health and fresh-claim e2e

Classic Showroom, honor system, **no Solve**. These playbooks do not complete
Tracks 1–7.

## healthcheck.yml

Post-provision readiness (< 60s). Confirms the v2 GitOps objects exist:

- Namespaces `lw-poc-build`, `lw-poc-staging`, `lw-poc-prod`
- NetworkPolicy `build-egress` / `app-operate`
- Incomplete ImageSet ConfigMap, oc-mirror tooling + PVC
- CronJob `trust-policy-apply`
- Tasks `verify-base-image` / `conforma-policy` / `prefetch-dependencies`
- Showroom CLI userinfo (`cosign`, `ec`, `oc-mirror`; `syft_baked=false`)

Does **not** require a mirrored Hummingbird image, a signature, or unsigned deny.

Expects the claim to enable `networkPolicy`, `admission`, `gitea`,
`lightwell-repo`, and `pipelines`.

## e2e.yml

Imports the health check, then asserts the **fresh-claim negatives**:

| Title item | Fresh-claim assertion | Pass-path |
|------------|----------------------|-----------|
| Mirror job | ImageSet still `REPLACE_ME`; Job `oc-mirror-learner` absent | V2-54 / Track 1 |
| Cosign verify internal | No PipelineRun in `lw-poc-build`; no digest on stage ImageStream | V2-54 / Track 5 |
| Admission deny | TrustPolicy seed `enforce: false`; no `ImagePolicy` `tssc-prod-admission` | V2-54 / Track 6.1 |

Re-running e2e after a learner finishes a track is expected to **fail**.

## Run

```bash
# From the repo root, kubeconfig already selected for the claim:
ansible-playbook qa-automation/healthcheck.yml
ansible-playbook qa-automation/e2e.yml

ansible-playbook --syntax-check qa-automation/healthcheck.yml
ansible-playbook --syntax-check qa-automation/e2e.yml
```

Requires `oc` on PATH and cluster-admin (or equivalent) on the claim.
