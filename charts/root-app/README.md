# charts/root-app — Lightwell TSSC App of Apps

Master Helm chart for the workshop GitOps sync path (`gitops_path: charts/root-app`). It generates ArgoCD `Application` resources for each enabled child chart under `charts/components/`.

## Sync waves

| Wave | Components | Role |
|------|------------|------|
| `10` | `rhtas`, `rhtpa`, `rhacs` | TSSC operators / platform (`rhtas` #4, `rhtpa` #5, `rhacs` #6) |
| `20` | `lightwell-repo` | Artifact manager (validated / remediated / OSV) (#7) |
| `30` | `rhdh` | Developer Hub (+ `lightwell-java-service` placeholder; full template in #12) |
| `40` | `spring-boot-lw-poc`, `parasol-app` | Sample apps (`spring-boot-lw-poc` #24 primary; `parasol-app` #8 optional) |
| `50` | `showroom` | Lab guide (last) |

Ordering is set via `argocd.argoproj.io/sync-wave` on each Application and documented in [values.yaml](values.yaml). Prefer operators → config → apps → showroom when adding components.

## Components

| Values key | Chart path | Default |
|------------|------------|---------|
| `components.rhtas` | `charts/components/rhtas` | disabled |
| `components.rhtpa` | `charts/components/rhtpa` | disabled |
| `components.rhacs` | `charts/components/rhacs` | disabled |
| `components.lightwellRepo` | `charts/components/lightwell-repo` | disabled |
| `components.rhdh` | `charts/components/rhdh` | disabled |
| `components.springBootLwPoc` | `charts/components/spring-boot-lw-poc` | disabled |
| `components.parasolApp` | `charts/components/parasol-app` | disabled (optional) |
| `components.showroom` | `charts/components/showroom` | disabled |

Child charts are Phase 1 / Phase 4 issues. Keep `enabled: false` until the corresponding chart exists and is ready to sync.

## Local validation

```bash
cd charts/root-app
helm lint .
helm template lightwell . --set deployer.domain=apps.cluster.example.com

# Render a single Application (child chart need not exist for root-app dry-run)
helm template lightwell . \
  --set components.rhtas.enabled=true \
  --set deployer.domain=apps.cluster.example.com
```

## Adding a component

1. Create `charts/components/<name>/` (standalone chart).
2. Add `components.<camelCase>` in `values.yaml` with `enabled`, `namespace`, and `syncWave`.
3. Add an Application block in `templates/applications.yaml`.
4. Enable via values when ready for ArgoCD sync.

## Related

- [charts/README.md](../README.md)
- [docs/repository-conventions.md](../../docs/repository-conventions.md)
- [examples/helm/](../../examples/helm/) — structural reference only
- Issue [#2](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/2)
