# AgnosticV drafts (staging)

In-repo **drafts** for the RHDP catalog item `published.lightwell-tssc-workshop.prod`.  
These files are **not** live catalog config until submitted to [`redhat-cop/agnosticv`](https://github.com/redhat-cop/agnosticv) (Babylon-documented AgnosticV project — Phase 5).

**Strategy:** **dev-first** (`dev.yaml` → `babylon-catalog-dev`), then **prod** (`prod.yaml`).  
**Do not** open upstream PRs without explicit human confirmation ([AGENTS.md](../AGENTS.md)).  
Full ladder: [SUBMISSION.md](./SUBMISSION.md) · umbrella [#20](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/20).

## Catalog identity (authoritative)

| Field | Value |
|-------|-------|
| Catalog item ID (prod) | `published.lightwell-tssc-workshop.prod` |
| AgnosticV target | https://github.com/redhat-cop/agnosticv |
| Environment type | `agd-v2.ocp-field-asset-cnv.prod` |
| Pool (document) | `agd-v2/ocp-virt-labs-pool` |
| GitOps path | `charts/root-app` |
| DEV catalog namespace | `babylon-catalog-dev` |
| Pattern | AgnosticD v2 Field Sourced Content |

## GitOps repo URL

| Stage | `gitops_repo` / `ocp4_workload_field_content_gitops_repo_url` |
|-------|----------------------------------------------------------------|
| **Now (draft)** | `https://github.com/NA-FSI-Services/lightwell-tssc-workshop.git` |
| After `rhpds` mirror | `https://github.com/rhpds/lightwell-tssc-workshop.git` |

## Layout

```
agnosticv/
├── README.md
├── SUBMISSION.md             # Dev → prod checklist + issue ladder
├── lightwell-tssc-workshop/  # Folder leaf (issue #71) — copy upstream for #73
│   ├── common.yaml           # includes __meta__.asset_uuid (#72)
│   ├── description.adoc
│   ├── dev.yaml              # babylon-catalog-dev
│   └── prod.yaml             # published.lightwell-tssc-workshop.prod
└── published/README.md       # Legacy path pointer
```

Validate locally: `./scripts/agnosticv-check.sh`

## Validated multi-node CNV sizing (issue #10)

| Role | Count | vCPU | RAM | Notes |
|------|-------|------|-----|-------|
| Control plane | 1 | 16 | 32 GB | Matches/exceeds RHADS-SSC **recommended** CP (8 cores / 32 GiB) |
| Workers | 2 | 16 | 64 GB each | Above RHADS-SSC **recommended** worker (8 cores / 24 GiB) for Tekton + RHACS headroom |

**Cluster shape:** 3-node multi-node OpenShift (1 CP + 2 workers). Do **not** drop to SNO for the full TSSC stack. Details and memory-pressure notes remain as previously validated in issue #10 / prior README revisions.

## Field Content variables

| Catalog / user_data (draft) | AgnosticD / role variable |
|-----------------------------|---------------------------|
| `gitops_repo` | `ocp4_workload_field_content_gitops_repo_url` |
| `gitops_path` | `ocp4_workload_field_content_gitops_repo_path` |
| `gitops_revision` | `ocp4_workload_field_content_gitops_repo_revision` |

RHDP injects `deployer.domain` and `deployer.apiUrl` into Helm values for `charts/root-app` at order time.

## Related

- [#9](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/9) — initial AgnosticV draft
- [#10](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/10) — CNV sizing
- [#20](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/20) — umbrella · [#71](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/71)–[#73](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/73) · [#21](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/21)–[#23](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/23)
- [DEVELOPMENT-PLAN.md](../DEVELOPMENT-PLAN.md) — Phase 5
- [DEV-CLUSTER-BOOTSTRAP.md](../docs/DEV-CLUSTER-BOOTSTRAP.md) — Ephemeral OCP claim QA via `claim.env` + `dev-cluster` Helm bootstrap
- [redhat-cop/babylon](https://github.com/redhat-cop/babylon) — AgnosticV Operator / CatalogItem materialization
