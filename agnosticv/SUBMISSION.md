# AgnosticV submission checklist (Phase 5)

**Upstream target (confirmed):** [`redhat-cop/agnosticv`](https://github.com/redhat-cop/agnosticv)  
**Strategy:** **dev-first**, then **prod**.

**Agents must not open upstream PRs without explicit human confirmation** ([AGENTS.md](../AGENTS.md)).

## Issue ladder

| Step | Issue | Outcome |
|------|-------|---------|
| 1 | [#71](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/71) | Reshape in-repo draft → folder layout (`common.yaml` + `dev.yaml` + `prod.yaml` + `description.adoc`) |
| 2 | [#72](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/72) | Real `asset_uuid` + schema validation |
| 3 | [#73](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/73) | Open **DEV** PR to `redhat-cop/agnosticv` |
| 4 | [#21](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/21) | Order / validate on `babylon-catalog-dev` |
| 5 | [#22](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/22) | Merge **prod** leaf; production CatalogItem orderable |
| 6 | [#23](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/23) | Field enablement announcement |

Umbrella: [#20](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/20).

## Babylon flow (why this order)

1. AgnosticV Operator watches the AgnosticV git repo ([babylon `agnosticv-operator`](https://github.com/redhat-cop/babylon/tree/main/agnosticv-operator)).
2. A `dev.yaml` leaf with `__meta__.catalog.namespace` → DEV catalog creates a DEV `CatalogItem`.
3. Order from DEV → ResourceClaim → Field Content GitOps sync → Showroom (#21).
4. After smoke success, add/promote `prod.yaml` for production (#22).

Optional: PR **preload** on the AgnosticV repo can expose a CatalogItem before merge for early #21 testing.

## Target repo note

Public [`redhat-cop/agnosticv`](https://github.com/redhat-cop/agnosticv) currently publishes the AgnosticV **CLI** and fixtures. Before the first PR (#73), confirm with maintainers the **exact directory** for workshop leaves inside that repository (contribution path may be guided by Babylon/RHDP even when this org/repo is the documented target).

## Validated GitOps fields (must match in `common.yaml` / leaves)

| Field | Value |
|-------|-------|
| Production catalog identity | `published.lightwell-tssc-workshop.prod` (do not invent alternates) |
| `gitops_repo` / `ocp4_workload_field_content_gitops_repo_url` | `https://github.com/NA-FSI-Services/lightwell-tssc-workshop.git` |
| `gitops_path` / `…_gitops_repo_path` | `charts/root-app` |
| `gitops_revision` / `…_gitops_repo_revision` | `main` |
| Environment type | `agd-v2.ocp-field-asset-cnv.prod` |
| Pool (documented) | `agd-v2/ocp-virt-labs-pool` |
| DEV catalog namespace | `babylon-catalog-dev` (or confirmed sibling) |

After an `rhpds/` content mirror exists, update GitOps URLs in the AgnosticV leaves ([DEVELOPMENT-PLAN.md](../DEVELOPMENT-PLAN.md)).

## Proposed in-repo layout (after #71)

```text
agnosticv/
├── README.md
├── SUBMISSION.md                 # This file
├── lightwell-tssc-workshop/      # folder leaf (preferred)
│   ├── common.yaml
│   ├── description.adoc
│   ├── dev.yaml                  # DEV first
│   └── prod.yaml                 # after #21
└── published/                    # legacy flat draft — keep until #71 migrates
    ├── published.lightwell-tssc-workshop.prod.yaml
    └── description.adoc
```

## Pre-flight (local)

```bash
./scripts/asciidoc-check.sh
./scripts/showroom-check.sh
./scripts/helm-validate.sh

# After #71:
# test -f agnosticv/lightwell-tssc-workshop/common.yaml
# test -f agnosticv/lightwell-tssc-workshop/dev.yaml
```

## Human steps — DEV PR (#73)

1. Complete #71 / #72 (or document maintainer waiver for UUID).
2. Confirm leaf path inside `redhat-cop/agnosticv` with maintainers.
3. Clone/fork `redhat-cop/agnosticv`; copy folder leaf (`common.yaml`, `description.adoc`, `dev.yaml`).
4. Open PR (dev-first; omit or clearly gate `prod.yaml` until #22).
5. Link PR URL on #73, #20, and DEVELOPMENT-PLAN.md.
6. Proceed to #21 (merge or preload).

## Human steps — prod (#22)

1. #21 smoke test passed.
2. PR to add/enable `prod.yaml` (and prod catalog namespace / stage labels).
3. Verify production CatalogItem orderable; record smoke test.
4. Hand off to #23 field enablement.

## Explicit non-goals for agents

* Inventing a new catalog ID or environment type
* Changing pool selection without human approval
* Pushing to `redhat-cop/agnosticv` without human confirmation
* Leading with production-only leaf before DEV validation
