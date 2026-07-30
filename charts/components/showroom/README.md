# charts/components/showroom — RHDP Showroom lab UI

Deploys the **Showroom** split-screen learner experience for this workshop:

| Pane | Source |
|------|--------|
| Lab guide | Antora build of `site.yml` → `docs/modules/ROOT` (Modules 1–5 + RHDA appendix) |
| Terminal | `quay.io/rhpds/openshift-showroom-terminal-ocp` proxied at `/terminal/` |

Promoted from `examples/helm/components/showroom` for issue [#19](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/19). Image pins follow [docs/SHOWROOM-UPDATE-SPEC.md](../../../docs/SHOWROOM-UPDATE-SPEC.md).

## Content path

| Setting | Value |
|---------|-------|
| `content.repoUrl` | This workshop Git repo |
| `content.repoRef` | `main` |
| `content.antoraPlaybook` | `site.yml` |
| UI theme | `rhpds/rhdp_showroom_theme` (declared in `site.yml`) |

Learners discover modules via `docs/modules/ROOT/nav.adoc` after Antora builds.

## Sync waves (inside this chart)

| Wave | Resources |
|------|-----------|
| `0` | Namespace |
| `1` | SA, RBAC, ConfigMaps, PVC |
| `2` | Deployment + Service |
| `3` | Route (`showroom.<deployer.domain>`) |
| `4` | RHDP `demo-userinfo-showroom` (`showroom_url`) |

Root App-of-Apps places this chart at sync wave **`50`** (last).

## RHDP userinfo

ConfigMap `demo-userinfo-showroom` exposes:

* `showroom_url` — primary access link (matches hello-world / field-content pattern)
* `modules`, `lab_entry`, `access_instructions`
* Labels: `demo.redhat.com/application: lightwell-tssc-workshop`, `demo.redhat.com/userinfo: ""`

## Nookbag / zero-touch

`nookbag.enabled` defaults to **`false`** (UPDATE-SPEC: unsupported for this catalog path). Leave off unless product explicitly requires a bundle.

## Local validation

```bash
helm lint charts/components/showroom
helm template showroom charts/components/showroom \
  --set deployer.domain=apps.cluster.example.com

helm template lightwell charts/root-app \
  --set components.showroom.enabled=true \
  --set deployer.domain=apps.cluster.example.com
```

## Enable from root-app

```bash
# components.showroom.enabled: true  (wave 50)
# content.* already points at this repo + site.yml
```

## Related

- Modules: `docs/modules/ROOT/pages/module-0{1..5}-*.adoc`
- Issue [#19](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/19)
- [charts/root-app/README.md](../../root-app/README.md)
