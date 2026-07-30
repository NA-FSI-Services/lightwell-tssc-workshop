# AgnosticV drafts (staging only)

In-repo **drafts** for the RHDP catalog item `published.lightwell-tssc-workshop.prod`.  
These files are **not** live catalog config until a human submits them to [`redhat-gpe/agnosticv`](https://github.com/redhat-gpe/agnosticv) (Phase 5 — issue [#20](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/20)).

**Do not** open a PR against `redhat-gpe/agnosticv` or request an `rhpds/` repo transfer without explicit human confirmation ([AGENTS.md](../AGENTS.md)).

## Catalog identity (authoritative)

| Field | Value |
|-------|-------|
| Catalog item ID | `published.lightwell-tssc-workshop.prod` |
| Environment type | `agd-v2.ocp-field-asset-cnv.prod` |
| Pool (document) | `agd-v2/ocp-virt-labs-pool` |
| GitOps path | `charts/root-app` |
| Pattern | AgnosticD v2 Field Sourced Content |

## GitOps repo URL

| Stage | `gitops_repo` / `ocp4_workload_field_content_gitops_repo_url` |
|-------|----------------------------------------------------------------|
| **Now (draft)** | `https://github.com/NA-FSI-Services/lightwell-tssc-workshop.git` |
| After `rhpds` mirror | `https://github.com/rhpds/lightwell-tssc-workshop.git` |

Update the draft YAML when the production mirror exists ([DEVELOPMENT-PLAN.md](../DEVELOPMENT-PLAN.md) — Production mirror plan).

## Proposed CNV sizing (see also #10)

| Role | Count | vCPU | RAM |
|------|-------|------|-----|
| Control plane | 1 | 16 | 32 GB |
| Workers | 2 | 16 | 64 GB |

Sizing is documented here for AgnosticV / pool conversation; validation of multi-node CNV capacity is issue [#10](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/10).

## Layout

```
agnosticv/
├── README.md                 # This file
└── published/
    ├── published.lightwell-tssc-workshop.prod.yaml   # Catalog + deployer draft
    └── description.adoc                              # Catalog description (AsciiDoc)
```

## Field Content variables

The Field Sourced Content path uses the `ocp4_workload_field_content` workload. Equivalent mappings:

| Catalog / user_data (draft) | AgnosticD / role variable |
|-----------------------------|---------------------------|
| `gitops_repo` | `ocp4_workload_field_content_gitops_repo_url` |
| `gitops_path` | `ocp4_workload_field_content_gitops_repo_path` |
| `gitops_revision` | `ocp4_workload_field_content_gitops_repo_revision` |

RHDP injects `deployer.domain` and `deployer.apiUrl` into the Helm values for `charts/root-app` at order time.

## Related

- Issue [#9](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/9) — this draft
- Issue [#10](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/10) — CNV sizing validation
- Issue [#20](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/20) — submit PR to `redhat-gpe/agnosticv`
- [DEVELOPMENT-PLAN.md](../DEVELOPMENT-PLAN.md) — Phase 2
