# AgnosticV submission checklist (Phase 5)

**Upstream target (confirmed):** [`redhat-cop/agnosticv`](https://github.com/redhat-cop/agnosticv)  
**Strategy:** **dev-first**, then **prod**.

**Agents must not open upstream PRs without explicit human confirmation** ([AGENTS.md](../AGENTS.md)).

## Issue ladder

| Step | Issue | Outcome |
|------|-------|---------|
| 1 | [#71](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/71) | Reshape in-repo draft → folder layout (`common.yaml` + `dev.yaml` + `prod.yaml` + `description.adoc`) |
| 2 | [#72](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/72) | Real `asset_uuid` + `scripts/agnosticv-check.sh` |
| 3 | [#73](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/73) | Open **DEV** PR to `redhat-cop/agnosticv` |
| 4 | [#21](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/21) | Order / validate on `babylon-catalog-dev` |
| 5 | [#22](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/22) | Merge **prod** leaf; production CatalogItem orderable |
| 6 | [#23](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/23) | Field enablement announcement |

Umbrella: [#20](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/20).

## RHDP demo / lab onboarding form

**Portal:** [https://red.ht/demo-onboarding](https://red.ht/demo-onboarding) (RHDP catalog asset intake; Jira Service Management).  
Not all submissions are approved — RHDP evaluates duplication, cost, and customer/associate value.

Record ticket / request ID on [#20](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/20) when submitted. Do **not** commit requester identity, emails, or credentials.

### Answers used for this workshop (sanitized)

| Form prompt | Response |
|-------------|----------|
| **Asset Title** | Lightwell Software Supply Chain Security Workshop |
| **Describe what you would like to build or onboard** | Hands-on RHDP workshop teaching Lightwell Network (Validated / Remediated / Java OSV) with TSSC controls on OpenShift: enterprise Maven, `.rhlw-*` exact-version pins, RHTPA SBOM, RHTAS signing, RHACS policy, GitOps. Field Sourced Content pattern (`agd-v2.ocp-field-asset-cnv.prod`); GitOps `NA-FSI-Services/lightwell-tssc-workshop` → `charts/root-app` @ `main`; DEV-first then prod ID `published.lightwell-tssc-workshop.prod`. Tracker: issue #20. |
| **What customer use cases or problems will this address?** | Governed OSS consumption when CVEs land without full upgrades; end-to-end demo of Lightwell tiers + Maven + SBOM + signing + policy; repeatable field enablement instead of one-off PoV rebuilds. |
| **Is this a lab or a demo?** | **Lab** (multi-participant Showroom exercises) |
| **Which TDP, Sales Play, and/or Sales Tactic?** | Lightwell Network field enablement / software supply chain security; related Trusted Software Supply Chain (RHTAS, RHTPA, RHACS, GitOps) and Application Developer / RHADS-aligned secure delivery. Prefer a named play from [Sales Plays overview](https://content.redhat.com/us/en/sales-enablement/sales-plays-overview.html) when submitting. |
| **How will you automate workload deployment?** | **Combination of Ansible and GitOps** (Helm + ArgoCD primary; ansible-runner only when Helm cannot express wait/secret/API logic) |
| **Related to AI or Machine Learning?** | **No** (Module 1 narrative mentions an “AI vulnerability storm”; workload is not AI/ML training or inference) |
| **Direct access to a GPU?** | **No** |
| **Can you use MaaS instead of direct GPU?** | **Yes** (no GPU required; avoids dedicated GPU capacity) |
| **Should it be made available to Partners?** | **No** for initial approval (associate / field first; expand later if needed) |

### Showroom note (common reviewer feedback)

Lab content is already Showroom/Antora in this monorepo (`docs/modules/ROOT/`, `site.yml`, `charts/components/showroom`) — Field Sourced Content pattern, not a separate [`showroom_template_nookbag`](https://github.com/rhpds/showroom_template_nookbag) repo. Optional polish via [create-lab skill](https://rhpds.github.io/rhdp-skills-marketplace/skills/create-lab.html); bootstrap from the nookbag template is **not** required.

**Module 1 terminal RBAC:** Showroom `/terminal/` uses SA `showroom:showroom`. Chart default `terminal.labClusterAccess: true` creates ClusterRoleBinding `showroom-lab-cluster-admin` so Module 1 `oc -n lightwell-repo get configmap …` works. Do **not** add HTPasswd IdP or kubeadmin passwords to AgnosticV — that is [dev-cluster QA only](../docs/DEV-CLUSTER-BOOTSTRAP.md). Catalog Helm values in [`common.yaml`](./lightwell-tssc-workshop/common.yaml) already enable `lightwellRepo` + `showroom` for Module 1 E2E.

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
| `__meta__.asset_uuid` | `46fb0d02-b90a-4a12-82b3-1a88f1e8c7d5` (see below) |

After an `rhpds/` content mirror exists, update GitOps URLs in the AgnosticV leaves ([DEVELOPMENT-PLAN.md](../DEVELOPMENT-PLAN.md)).

## `asset_uuid` (#72)

| | |
|--|--|
| Value | `46fb0d02-b90a-4a12-82b3-1a88f1e8c7d5` |
| Location | `agnosticv/lightwell-tssc-workshop/common.yaml` → `__meta__.asset_uuid` |
| Source | Generated **2026-07-30** with `uuidgen | tr '[:upper:]' '[:lower:]'` per RHDP AgnosticV schema-checker guidance (RFC 4122 lowercase; must stay unique across the upstream AgV repo) |
| CatalogItem label | `gpte.redhat.com/asset-uuid` |
| Validation | `./scripts/agnosticv-check.sh` (structure, UUID, category, GitOps invariants, DEV/PROD merge). Full `agnosticv --merge` + `.schemas/babylon.yaml` when those are available locally. |

Do **not** reuse the retired placeholder `00000000-0000-4000-8000-000000000009`.

## In-repo layout (#71)

```text
agnosticv/
├── README.md
├── SUBMISSION.md                 # This file
├── lightwell-tssc-workshop/      # folder leaf for upstream copy
│   ├── common.yaml               # shared GitOps + base __meta__
│   ├── description.adoc
│   ├── dev.yaml                  # babylon-catalog-dev
│   └── prod.yaml                 # published.lightwell-tssc-workshop.prod
└── published/README.md           # pointer to lightwell-tssc-workshop/
```

**Maintainer path TBD:** confirm exact directory inside [`redhat-cop/agnosticv`](https://github.com/redhat-cop/agnosticv) before #73 (public repo is CLI-centric today).

## Pre-flight (local)

```bash
./scripts/asciidoc-check.sh
./scripts/showroom-check.sh
./scripts/helm-validate.sh

test -f agnosticv/lightwell-tssc-workshop/common.yaml
test -f agnosticv/lightwell-tssc-workshop/description.adoc
test -f agnosticv/lightwell-tssc-workshop/dev.yaml
test -f agnosticv/lightwell-tssc-workshop/prod.yaml
grep -q 'babylon-catalog-dev' agnosticv/lightwell-tssc-workshop/dev.yaml
grep -q 'published.lightwell-tssc-workshop.prod' agnosticv/lightwell-tssc-workshop/prod.yaml
grep -q 'charts/root-app' agnosticv/lightwell-tssc-workshop/common.yaml
./scripts/agnosticv-check.sh
```

## Human steps — DEV PR (#73)

1. Complete #71 / #72 (UUID + `agnosticv-check` green).
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
