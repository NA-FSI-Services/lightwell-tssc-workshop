# charts/components/rhacs — Red Hat Advanced Cluster Security

Deploys RHACS **Central** (and optional same-cluster **SecuredCluster**) via the RHACS Operator, plus Tekton **policy gates** for Lightwell non-remediated vs `.rhlw-*` pins, `roxctl image check`, and CycloneDX SBOM handoff to RHTPA.

## Sync waves (inside this chart)

| Wave | Resources |
|------|-----------|
| `0` | Namespaces (`stackrox`, `rhacs-operator`) |
| `1` | OperatorGroup + Subscription |
| `2` | `Central` CR |
| `3` | `SecuredCluster` CR |
| `4` | Tekton Tasks / Pipeline + CI secret + lab ConfigMaps |
| `5` | RHDP userinfo ConfigMap |

Root App-of-Apps places this chart at sync wave **`10`**.

## Pipeline policy gates (issue #13)

| Artifact | Purpose |
|----------|---------|
| Task `lightwell-dep-gate` | Fail when default Maven pin lacks `.rhlw-*` (OSV-friendly / deterministic) |
| Task `acs-image-check` | `roxctl image check` against Central BUILD policies (Clair/OSV-class) |
| Task `syft-sbom-rhtpa` | syft CycloneDX SBOM (distroless ENTRYPOINT) + UBI publish/upload to RHTPA |
| Pipeline `lightwell-build-policy-gate` | clone → dep-gate → ACS check → SBOM |
| ConfigMap `rhacs-lightwell-policy-lab` | Fail / success lab narrative |
| ConfigMap `rhacs-lightwell-central-policy` | Importable Fixable Critical BUILD policy JSON |

### Failure path (non-remediated)

```bash
# spring-boot-lw-poc default properties pin is 3.14.0 (no .rhlw-*)
oc -n stackrox create -f - <<'EOF'
# see ConfigMap rhacs-lightwell-policy-lab key fail_pipelinerun.yaml
EOF
# Expect Task lightwell-dep-gate to fail
```

### Success path (`.rhlw-*`)

1. Set default `<commons.lang3.version>3.14.0.rhlw-00001</commons.lang3.version>` in the app `pom.xml` properties.
2. Re-run the Pipeline — dep-gate passes.
3. Populate CI secrets; import Central Fixable Critical policy for real `roxctl` fails/passes on scanned images.
4. Confirm SBOM in RHTPA UI (or `upload-status=uploaded` when `rhtpa-url` + token are set).

### CI secrets

```bash
oc -n stackrox create secret generic rhacs-ci-secrets \
  --from-literal=rox-api-endpoint='central-stackrox.apps.<domain>:443' \
  --from-literal=rox-api-token='<TOKEN>' \
  --dry-run=client -o yaml | oc apply -f -
```

Optional RHTPA upload token: Secret `rhtpa-upload-token` key `token`.

## Reuse sources

- RHACS Demo: `agd-v2.rhacs-demo-cnv.prod`
- [Installing RHACS on OpenShift](https://docs.redhat.com/en/documentation/red_hat_advanced_cluster_security_for_kubernetes/4.7/html/installing/installing-rhacs-on-red-hat-openshift)
- TSSC / RHADS Tekton `acs-image-check` / `rox-image-check` task patterns

## Values of interest

| Key | Default | Notes |
|-----|---------|-------|
| `rhacs.namespace` | `stackrox` | Central + SecuredCluster + gate Tasks |
| `pipelineHooks.depGate.remediatedVersion` | `3.14.0.rhlw-00001` | Success pin |
| `pipelineHooks.pipeline.defaultPomPath` | `charts/.../spring-boot-lw-poc/app/pom.xml` | Monorepo lab path |
| `pipelineHooks.sbom.rhtpaUrl` | `""` | Set when RHTPA Route known |
| `pipelineHooks.failOnSkipped` | `"false"` | Set `"true"` to fail ACS task without secrets |
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

- Issue [#6](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/6) — chart scaffold
- Issue [#13](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/13) — policy gates
- [charts/root-app/README.md](../../root-app/README.md)
