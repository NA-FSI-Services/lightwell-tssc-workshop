# charts/components/rhacs — Red Hat Advanced Cluster Security

Deploys RHACS **Central** (and optional same-cluster **SecuredCluster**) via the RHACS Operator, plus a Tekton Task that runs **`roxctl image check`** for pipeline policy gates.

## Sync waves (inside this chart)

| Wave | Resources |
|------|-----------|
| `0` | Namespaces (`stackrox`, `rhacs-operator`) |
| `1` | OperatorGroup + Subscription |
| `2` | `Central` CR |
| `3` | `SecuredCluster` CR |
| `4` | Tekton Task + CI secret placeholder + hooks info |
| `5` | RHDP userinfo ConfigMap |

Root App-of-Apps places this chart at sync wave **`10`**.

## Pipeline policy hooks (`roxctl image check`)

| Artifact | Purpose |
|----------|---------|
| Tekton Task `acs-image-check` | Downloads `roxctl` from Central and runs `image check` (JSON) |
| Secret `rhacs-ci-secrets` | Placeholder for `rox-api-endpoint` / `rox-api-token` (inject token after Central is Ready) |
| ConfigMap `rhacs-pipeline-hooks-info` | Example Pipeline task snippet + CLI sample |

After Central is Ready:

```bash
# Create CI API token in Central UI, then:
oc -n stackrox create secret generic rhacs-ci-secrets \
  --from-literal=rox-api-endpoint='central-stackrox.apps.<domain>:443' \
  --from-literal=rox-api-token='<TOKEN>' \
  --dry-run=client -o yaml | oc apply -f -
```

Phase 3 [#13](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/13) expands Central policies / pipeline wiring for non-remediated Lightwell pins.

## Reuse sources

- RHACS Demo: `agd-v2.rhacs-demo-cnv.prod`
- [Installing RHACS on OpenShift](https://docs.redhat.com/en/documentation/red_hat_advanced_cluster_security_for_kubernetes/4.7/html/installing/installing-rhacs-on-red-hat-openshift)
- TSSC / RHADS Tekton `acs-image-check` / `rox-image-check` task patterns

## Values of interest

| Key | Default | Notes |
|-----|---------|-------|
| `rhacs.namespace` | `stackrox` | Central + SecuredCluster |
| `operator.namespace` | `rhacs-operator` | Recommended Operator NS |
| `central.persistence.pvcSize` | `50Gi` | Workshop-sized |
| `securedCluster.enabled` | `true` | Same-cluster Sensor / Admission |
| `pipelineHooks.enabled` | `true` | Tekton Task + secret placeholder |
| `deployer.domain` | `""` | Injected by root-app |

## Local validation

```bash
helm lint charts/components/rhacs
helm template rhacs charts/components/rhacs \
  --set deployer.domain=apps.cluster.example.com

./scripts/helm-validate.sh
```

## Enable from root-app

```bash
helm template lightwell charts/root-app \
  --set components.rhacs.enabled=true \
  --set deployer.domain=apps.cluster.example.com
```

Keep `components.rhacs.enabled: false` in committed root values until cluster capacity is ready.

## Related

- Issue [#6](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/6)
- Follow-up policy gates: [#13](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/13)
- [charts/root-app/README.md](../../root-app/README.md)
