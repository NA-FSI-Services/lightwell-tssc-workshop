# AgnosticV submission checklist (issue #20)

Prepare and submit `published.lightwell-tssc-workshop.prod` to [`redhat-gpe/agnosticv`](https://github.com/redhat-gpe/agnosticv).

**Agents must not open that PR without explicit human confirmation** ([AGENTS.md](../AGENTS.md)).

## Source of truth (this repo)

| Artifact | Path |
|----------|------|
| Catalog YAML draft | [`published/published.lightwell-tssc-workshop.prod.yaml`](./published/published.lightwell-tssc-workshop.prod.yaml) |
| Catalog description | [`published/description.adoc`](./published/description.adoc) |
| Sizing / pool notes | [`README.md`](./README.md) |

## Validated GitOps fields (must match)

| Field | Value |
|-------|-------|
| Catalog item ID | `published.lightwell-tssc-workshop.prod` |
| `gitops_repo` / `ocp4_workload_field_content_gitops_repo_url` | `https://github.com/NA-FSI-Services/lightwell-tssc-workshop.git` |
| `gitops_path` / `…_gitops_repo_path` | `charts/root-app` |
| `gitops_revision` / `…_gitops_repo_revision` | `main` |
| Environment type | `agd-v2.ocp-field-asset-cnv.prod` |
| Pool (documented) | `agd-v2/ocp-virt-labs-pool` |

After an `rhpds/` mirror exists, update both draft YAML and the upstream AgnosticV file to the `rhpds` Git URL ([DEVELOPMENT-PLAN.md](../DEVELOPMENT-PLAN.md)).

## Pre-flight (local)

```bash
# Draft present and IDs stable
test -f agnosticv/published/published.lightwell-tssc-workshop.prod.yaml
grep -q 'published.lightwell-tssc-workshop.prod' \
  agnosticv/published/published.lightwell-tssc-workshop.prod.yaml

# GitOps path still App-of-Apps
test -f charts/root-app/Chart.yaml
grep -q 'enabled: true' charts/root-app/values.yaml   # showroom at minimum

# Content + Showroom contract
./scripts/asciidoc-check.sh
./scripts/showroom-check.sh
./scripts/helm-validate.sh
```

## Human steps to open the upstream PR

1. Confirm catalog onboarding: real `__meta__.asset_uuid` (replace placeholder `00000000-0000-4000-8000-000000000009`), catalog namespace (`babylon-catalog-dev` for stage), icons / terms includes per sibling Workshop items.
2. Clone or fork `redhat-gpe/agnosticv` with write access.
3. Copy:
   - `agnosticv/published/published.lightwell-tssc-workshop.prod.yaml` → `published/published.lightwell-tssc-workshop.prod.yaml`
   - Align `description.adoc` with whatever pattern sibling items use (inline `__meta__.catalog.description` vs adjacent file).
4. Diff against a recent Field Sourced Content / Workshop item for required includes (`__meta__` keys, labels, lifespan).
5. Open PR to `redhat-gpe/agnosticv` with title/body referencing catalog ID + GitOps repo/path/revision.
6. Link that PR URL from issue [#20](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/20) and [DEVELOPMENT-PLAN.md](../DEVELOPMENT-PLAN.md) Phase 5.
7. Continue [#21](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/21) staging on `babylon-catalog-dev` after merge.

## Explicit non-goals for agents

* Inventing a new catalog ID or environment type
* Changing pool selection without human approval
* Pushing to `redhat-gpe/agnosticv` or requesting `rhpds/` transfer without confirmation
