# charts/components/rhdh — Red Hat Developer Hub

Deploys Developer Hub for the Lightwell TSSC workshop via the **RHDH Operator** (OLM Subscription) and a `Backstage` custom resource. Ships the **lightwell-java-service** Software Template (Maven + LWN Validated/Remediated profiles, `LW_*` auth placeholders, `.rhlw-*` pins, RHTAS keyless Tekton pipeline).

## Sync waves (inside this chart)

| Wave | Resources |
|------|-----------|
| `0` | Namespaces (`rhdh`, `rhdh-operator`) |
| `1` | OperatorGroup + Subscription |
| `2` | app-config / dynamic-plugins / software-templates ConfigMaps |
| `3` | `Backstage` CR |
| `4` | RHDP `demo-userinfo-rhdh` ConfigMap |

Root App-of-Apps places this chart at sync wave **`30`** (after operators / lightwell-repo).

## What gets created

- **Operator** in `rhdh-operator` (AllNamespaces OperatorGroup + `redhat-operators` Subscription `rhdh`, channel `fast`)
- **Instance** in `rhdh`: `Backstage` CR `developer-hub`, local PostgreSQL, OpenShift Route
- **Catalog**: ConfigMap-mounted Template `lightwell-java-service`
- **Skeleton** (fetched at scaffold time from Git): `files/skeletons/lightwell-java-service/`
- **Userinfo** labeled for RHDP (`demo.redhat.com/application`, `demo.redhat.com/userinfo`)

## Software Template — lightwell-java-service

| Concern | Implementation |
|---------|----------------|
| Maven profiles | `settings.xml` → `lightwell-validated` + `lightwell-remediated` |
| Auth | `${env.LW_USERNAME}` / `${env.LW_PASSWORD}` (never commit secrets) |
| Dual streams + pin | `pom.xml` profiles; `commons-lang3` `3.14.0.rhlw-00001` |
| RHTAS keyless | `.tekton/pipeline.yaml` → `cosign sign` (Fulcio/Rekor params) |
| Modules 2–6 | Skeleton `docs/MODULES.md` + template output text |

Scaffolder steps: `fetch:template` from Gitea `workshop-templates/lightwell-java-service`
→ `publish:gitea` → `catalog:register`.

**Requires** in-cluster Gitea integration (`integrations.gitea` + dynamic plugin
`scaffolder-backend-module-gitea`) and scaffolder credentials (Secret `rhdh-gitea-scaffolder`).
Learners delete the Module 2 app repo `lw-<username>/spring-boot-lw-poc` first, then Create
publishes into the **same** learner organization (Showroom Module 3). Upstream `publish:gitea`
requires a Gitea Organization — learners create `lw-<username>` in Module 2; the seed Job only
prepares `workshop-templates/` content and student user accounts.

Skeleton URL (after merge to `main`):

```text
https://github.com/NA-FSI-Services/lightwell-tssc-workshop/tree/main/charts/components/rhdh/files/skeletons/lightwell-java-service
```

## Reuse sources

- RHADS Demo catalog / Software Template patterns (`enterprise.redhat-ads-demo.prod` / `pert.redhat-rhads.prod`)
- [Installing RHDH on OpenShift with the Operator](https://docs.redhat.com/en/documentation/red_hat_developer_hub/1.10/html-single/installing_red_hat_developer_hub_on_openshift_container_platform/index)
- Field-sourced template OLM Subscription pattern (`examples/helm/components/operator`)
- In-repo PoC: [`charts/components/spring-boot-lw-poc`](../spring-boot-lw-poc/)

## Values of interest

| Key | Default | Notes |
|-----|---------|-------|
| `rhdh.enabled` | `true` | Chart gate |
| `rhdh.namespace` | `rhdh` | Instance namespace |
| `rhdh.apiVersion` | `rhdh.redhat.com/v1alpha5` | Override if channel CRD differs |
| `operator.enabled` | `true` | Set `false` if Operator already installed |
| `operator.channel` | `fast` | Or `fast-1.10` for z-stream only |
| `softwareTemplates.enabled` | `true` | Mount Template catalog entity |
| `deployer.domain` | `""` | Injected by root-app; used for `baseUrl` / userinfo |

Auth (workshop): `app-config-rhdh` sets `auth.environment: development`, guest provider with
`dangerouslyAllowOutsideDevelopment: true`, and `signInPage: guest` so learners use **Guest**
only (no GitHub OAuth — that button otherwise 404s with `Unknown auth provider 'github'`).

Canonical LWN remotes:

- `https://packages.redhat.com/lightwell/java/validated`
- `https://packages.redhat.com/lightwell/java/remediated`
- `https://packages.redhat.com/lightwell/osv/java/remediated`

## Local validation

```bash
helm lint charts/components/rhdh
helm template rhdh charts/components/rhdh \
  --set deployer.domain=apps.cluster.example.com

./scripts/helm-validate.sh
```

## Enable from root-app

```bash
helm template lightwell charts/root-app \
  --set components.rhdh.enabled=true \
  --set deployer.domain=apps.cluster.example.com
```

Keep `components.rhdh.enabled: false` in committed root values until a cluster is ready to sync this chart.

## Related

- Issue [#3](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/3) — chart scaffold
- Issue [#12](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/12) — this template
- [charts/root-app/README.md](../../root-app/README.md)
