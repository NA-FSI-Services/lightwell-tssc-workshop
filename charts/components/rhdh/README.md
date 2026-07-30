# charts/components/rhdh — Red Hat Developer Hub

Deploys Developer Hub for the Lightwell TSSC workshop via the **RHDH Operator** (OLM Subscription) and a `Backstage` custom resource. Includes a **placeholder** Software Template `lightwell-java-service` (Maven + LWN profiles land in [#12](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/12)).

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
- **Catalog**: ConfigMap-mounted `files/catalog/lightwell-java-service.yaml` (Template entity placeholder)
- **Userinfo** labeled for RHDP (`demo.redhat.com/application`, `demo.redhat.com/userinfo`)

## Reuse sources

- RHADS Demo catalog patterns (`enterprise.redhat-ads-demo.prod` / `pert.redhat-rhads.prod`)
- [Installing RHDH on OpenShift with the Operator](https://docs.redhat.com/en/documentation/red_hat_developer_hub/1.10/html-single/installing_red_hat_developer_hub_on_openshift_container_platform/index)
- Field-sourced template OLM Subscription pattern (`examples/helm/components/operator`)

## Values of interest

| Key | Default | Notes |
|-----|---------|-------|
| `rhdh.enabled` | `true` | Chart gate |
| `rhdh.namespace` | `rhdh` | Instance namespace |
| `rhdh.apiVersion` | `rhdh.redhat.com/v1alpha3` | Override if channel CRD differs |
| `operator.enabled` | `true` | Set `false` if Operator already installed |
| `operator.channel` | `fast` | Or `fast-1.10` for z-stream only |
| `softwareTemplates.enabled` | `true` | Placeholder Template catalog mount |
| `deployer.domain` | `""` | Injected by root-app; used for `baseUrl` / userinfo |

Canonical LWN remotes (documented on the Template placeholder):

- `https://packages.redhat.com/lightwell/java/validated`
- `https://packages.redhat.com/lightwell/java/remediated`
- `https://packages.redhat.com/lightwell/osv/java/remediated`

## Local validation

```bash
helm lint charts/components/rhdh
helm template rhdh charts/components/rhdh \
  --set deployer.domain=apps.cluster.example.com

# Or full tree
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

- Issue [#3](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/3)
- Follow-up template implementation: [#12](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/12)
- [charts/root-app/README.md](../../root-app/README.md)
