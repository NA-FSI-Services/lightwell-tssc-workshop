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

## Validated multi-node CNV sizing (issue #10)

| Role | Count | vCPU | RAM | Notes |
|------|-------|------|-----|-------|
| Control plane | 1 | 16 | 32 GB | Matches/exceeds RHADS-SSC **recommended** CP (8 cores / 32 GiB) |
| Workers | 2 | 16 | 64 GB each | Above RHADS-SSC **recommended** worker (8 cores / 24 GiB) for Tekton + RHACS headroom |

**Cluster shape:** 3-node multi-node OpenShift (1 CP + 2 workers) — same floor RHADS-SSC documents for a full TSSC-class install (RHDH, GitOps, Pipelines, RHACS, RHTAS, RHTPA).

**Total worker capacity:** ~32 vCPU / ~128 GiB RAM available to workshop workloads (minus OpenShift system reserved).

### Validation against reuse catalog / pool capabilities

| Source | Finding |
|--------|---------|
| Pool target | `agd-v2/ocp-virt-labs-pool` — virt-labs CNV pool used by agd-v2 Field Content / workshop-style orders (not the sandbox `agd-v2/ocp-cluster-cnv-pools` item used for CI tenant scaling). |
| Environment | `agd-v2.ocp-field-asset-cnv.prod` — pre-warmed multi-node CNV claim (~10–15 min + GitOps sync). |
| Reuse items | RHADS Demo / Trusted Software Factory CNV / RHACS Demo CNV assume multi-node OpenShift capable of co-hosting operators + Pipelines; this workshop overlays the same operator family plus Nexus + sample apps. |
| RHADS-SSC hardware guide ([docs.redhat.com](https://docs.redhat.com/en/documentation/red_hat_advanced_developer_suite_-_software_supply_chain/1.9/html-single/installing_red_hat_advanced_developer_suite_-_software_supply_chain/index)) | Per-node **minimum** workers 5 CPU / 17 GiB; **recommended** 8 CPU / 24 GiB. Our **16 / 64** workers leave headroom for concurrent PipelineRuns and Scanner spikes beyond a bare RHADS install. |
| Chart defaults in this repo | Steady-state requests are modest (e.g. Nexus 2–4 Gi, RHTPA PostgreSQL 0.5–1 Gi, sample apps under 1 Gi). Spikes come from **Tekton task pods** and **RHACS Scanner / image check**, not from the Deployments alone. |

**Conclusion:** Keep the proposed sizing for AgnosticV / pool conversation. Do **not** drop to SNO or single-worker CNV for the full stack. If a pool SKU only offers smaller workers, prefer **more workers at ≥8 CPU / 24 GiB** over shrinking below RHADS recommended, and re-validate before changing catalog IDs or pool selection (human-gated per AGENTS.md).

### Memory pressure risks (Tekton + RHACS)

Call these out in labs and when enabling components on a shared claim:

1. **Concurrent PipelineRuns** — Maven build + `syft` + `roxctl image check` in parallel can each allocate multiple GiB. Prefer **one active learner pipeline** (or tight `max` concurrency) on a single claim.
2. **RHACS Scanner** — Central Scanner replicas (chart default `2`) and image analysis compete with PipelineRuns; avoid stacking many `acs-image-check` tasks at once.
3. **RHACS Central DB / PVC** — CVE DB and scan results grow; workshop PVCs are sized for PoC, not long-lived multi-tenant load.
4. **RHTPA SBOM ingest** — Large CycloneDX uploads spike PostgreSQL + analyzer CPU/RAM briefly after Module 4 steps.
5. **Nexus (`lightwell-repo`)** — Warm Maven caches and large proxy pulls stress heap (limit 4 Gi); seed mirrors offline when possible to avoid thundering herds.
6. **Node eviction** — If workers approach memory pressure, Pipelines fail first (evicted TaskRuns). Mitigate by disabling optional `parasol-app`, limiting Showroom terminal count, and not enabling every component until sync waves settle.

Optional `parasol-app` is fine on this sizing when the primary Spring Boot PoC is idle; treat it as **optional load**, not part of the minimum footprint.

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

- Issue [#9](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/9) — AgnosticV draft
- Issue [#10](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/10) — CNV sizing validation (this section)
- Issue [#20](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/20) — submit PR to `redhat-gpe/agnosticv`
- [DEVELOPMENT-PLAN.md](../DEVELOPMENT-PLAN.md) — Phase 2
