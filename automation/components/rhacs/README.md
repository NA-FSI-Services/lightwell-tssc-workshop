# charts/components/rhacs — Red Hat Advanced Cluster Security

Deploys RHACS **Central** (and optional same-cluster **SecuredCluster**) via the RHACS Operator, plus Tekton **policy gates** for Lightwell non-remediated vs `.rhlw-*` pins, `roxctl image check`, and CycloneDX SBOM handoff to RHTPA.

## Sync waves (inside this chart)

| Wave | Resources |
|------|-----------|
| `0` | Namespaces (`stackrox`, `rhacs-operator`) |
| `1` | OperatorGroup + Subscription |
| `2` | `Central` CR |
| `3` | `SecuredCluster` CR |
| `4` | Tekton Tasks / Pipeline + CI secret placeholder + lab ConfigMaps |
| `5` | Job `rhacs-ci-token-mint` (Central CI API token → `rhacs-ci-secrets`) |
| `6` | RHDP userinfo ConfigMap |

Root App-of-Apps places this chart at sync wave **`10`**.

**Prerequisite:** enable `components.pipelines` (wave **8**) so Tekton CRDs exist before
wave-`4` Tasks/Pipeline in this chart sync. See [`charts/components/pipelines`](../pipelines/).

## Pipeline policy gates (issues #13 / #149)

| Artifact | Purpose |
|----------|---------|
| Task `lightwell-dep-gate` | Fail when default Maven pin lacks `.rhlw-*` (OSV-friendly / deterministic) |
| Task `lightwell-python-dep-gate` | Fail when `requirements.txt` lacks `lw-workshop-pypi==*+rhlw.*` |
| Task `acs-image-check` | `roxctl image check` against Central BUILD policies (Clair/OSV-class) |
| Task `syft-sbom-rhtpa` | syft CycloneDX SBOM (distroless ENTRYPOINT) + UBI publish/upload to RHTPA |
| Pipeline `lightwell-build-policy-gate` | clone → Maven dep-gate → ACS check → SBOM |
| Pipeline `lightwell-python-build-policy-gate` | clone → Python dep-gate → ACS check → SBOM |
| ConfigMap `rhacs-lightwell-policy-lab` | Java fail / success lab narrative |
| ConfigMap `rhacs-lightwell-python-policy-lab` | Python fail / success lab narrative |
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

### Python failure / success (`lw-workshop-pypi`)

```bash
# Default fastapi-lw-poc requirements.txt has Validated httpx only (no marker pin)
oc -n stackrox get configmap rhacs-lightwell-python-policy-lab \
  -o jsonpath='{.data.fail_pipelinerun\.yaml}' | oc create -f -
# Expect Task lightwell-python-dep-gate to fail
```

1. Add `lw-workshop-pypi==1.0.0+rhlw.00001` to `requirements.txt` in the student FastAPI repo and push.
2. Re-run Pipeline `lightwell-python-build-policy-gate` — python-dep-gate passes.
3. Full build → sign → GitOps promote uses learner `.tekton/fastapi-lw-poc-build-sign` (Module 9).

### CI secrets

Dev claim (cluster-admin + Central Ready):

```bash
./scripts/dev-cluster-rhacs-ci-token.sh
```

Manual (never commit the token):

```bash
oc -n stackrox create secret generic rhacs-ci-secrets \
  --from-literal=rox-api-endpoint='central-stackrox.apps.<domain>:443' \
  --from-literal=rox-api-token='<TOKEN>' \
  --dry-run=client -o yaml | oc apply -f -
```

Helm ships `rox-api-endpoint` only; root-app `ignoreDifferences` on Secret `/data` keeps a patched token across syncs.

Optional RHTPA upload token: Secret `rhtpa-upload-token` key `token`.

## Reuse sources

- RHACS Demo: `agd-v2.rhacs-demo-cnv.prod`
- [Installing RHACS on OpenShift](https://docs.redhat.com/en/documentation/red_hat_advanced_cluster_security_for_kubernetes/4.7/html/installing/installing-rhacs-on-red-hat-openshift)
- TSSC / RHADS Tekton `acs-image-check` / `rox-image-check` task patterns

## Values of interest

| Key | Default | Notes |
|-----|---------|-------|
| `rhacs.namespace` | `stackrox` | Central + SecuredCluster + gate Tasks |
| `pipelineHooks.depGate.remediatedVersion` | `3.14.0.rhlw-00001` | Java success pin |
| `pipelineHooks.pythonDepGate.remediatedVersion` | `1.0.0+rhlw.00001` | Python success pin |
| `pipelineHooks.labRepoUrl` | `""` | Student Gitea URL (root-app injects when `gitea` enabled) |
| `pipelineHooks.pipeline.defaultPomPath` | `pom.xml` | Student repo root (not the GitOps monorepo) |
| `pipelineHooks.pythonPipeline.defaultRequirementsPath` | `requirements.txt` | FastAPI student repo root |
| `pipelineHooks.sbom.rhtpaUrl` | `""` | Set when RHTPA Route known |
| `pipelineHooks.ciTokenJob.enabled` | `true` | Mint CI token into `rhacs-ci-secrets` after Central Ready |
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
