# Repository conventions

This repository was bootstrapped from the [RHDP field-sourced-content template](https://github.com/rhpds/field-sourced-content-template) and is being specialized for the Lightwell TSSC workshop catalog item (`agd-v2.ocp-field-asset-cnv.prod`).

## Provenance

| Item | Value |
|------|-------|
| Upstream template | https://github.com/rhpds/field-sourced-content-template |
| Current development repo | https://github.com/NA-FSI-Services/lightwell-tssc-workshop |
| Intended RHDP production mirror | https://github.com/rhpds/lightwell-tssc-workshop |
| AgnosticD pattern | Field Sourced Content / GitOps (ArgoCD syncs this Git repo) |
| Environment type | `agd-v2.ocp-field-asset-cnv.prod` |

The `examples/` tree and `roles/ocp4_workload_field_content/` remain from the template as **reference and platform integration** material. Workshop production GitOps content lives under `charts/`.

## Directory map

```
lightwell-tssc-workshop/
├── charts/                          # PRODUCTION GitOps content (RHDP sync target)
│   ├── root-app/                    # App-of-Apps Helm chart (gitops_path)
│   └── components/                  # Child charts (rhdh, rhtas, rhtpa, …)
├── examples/
│   ├── helm/                        # Template REFERENCE: App-of-Apps pattern
│   └── ansible/                     # Template REFERENCE: ansible-runner Job pattern
├── roles/
│   └── ocp4_workload_field_content/ # AgnosticD field-content workload role (platform)
├── agnosticv/                       # STAGING only — AgnosticV catalog drafts (#9); not live until #20
│   └── published/                   # Draft published.lightwell-tssc-workshop.prod.yaml
├── tools/
│   └── osv-eval/                    # Module 3 OSV → .rhlw-* pin → source-diff helpers (#25)
├── docs/
│   ├── modules/                     # Showroom AsciiDoc labs (+ rhda-shift-left.adoc partial)
│   ├── rhda-rhtpa-shift-left.md     # Module 4 RHDA vs RHTPA (laptop vs Showroom)
│   ├── repository-conventions.md    # This file
│   ├── ansible-developer-guide.md
│   └── SHOWROOM-UPDATE-SPEC.md
├── DEVELOPMENT-PLAN.md
├── AGENTS.md
└── README.md
```


## Helm App-of-Apps (primary path)

**Use for:** operators, apps, Showroom, and anything expressible as Kubernetes/Helm manifests.

| Path | Role |
|------|------|
| `charts/root-app/` | Master chart; generates ArgoCD `Application` resources for each enabled component. This is the AgnosticV `gitops_path`. |
| `charts/components/<name>/` | Standalone Helm charts (one concern each). |
| `examples/helm/` | Working **reference** from the template. Copy patterns (values keys, Application templates, sync waves)—do not point RHDP production sync here once `charts/root-app` exists. |

### Conventions

- Enable/disable components via `charts/root-app` values (mirror `examples/helm/values.yaml` `components.*` pattern).
- Prefer ArgoCD sync waves: operators → config/secrets → apps → showroom.
- Label RHDP health / userinfo resources as documented in [README.md](../README.md).
- Keep component charts independently `helm template`-able.

Target components (see [DEVELOPMENT-PLAN.md](../DEVELOPMENT-PLAN.md) and project issues):

`rhdh`, `rhtas`, `rhtpa`, `rhacs`, `lightwell-repo`, `spring-boot-lw-poc`, optional `parasol-app`, plus Showroom content wiring.

## Ansible runner (optional path)

**Use for:** wait-for-ready, secret generation, external API calls, or conditional logic that Helm cannot express cleanly.

| Path | Role |
|------|------|
| `examples/ansible/` | Template **reference**: Helm chart that launches an ansible-runner Job + sample playbooks/roles. |
| `docs/ansible-developer-guide.md` | Patterns for embedding Ansible in field-sourced charts. |
| `docs/images/ansible-runner/` | Container build notes for the runner image. |

### Conventions

- Production Ansible (if needed) should ship as a component under `charts/components/<name>/` (Job + ConfigMap/playbooks), following `examples/ansible/`, not as a second top-level sync path.
- Keep the RHDP catalog sync source type as Helm (hybrid model): Ansible runs inside Jobs ordered by sync waves.
- Do not put Lightwell lab narrative solely in Ansible; prefer Showroom AsciiDoc under `docs/modules/`.

## Showroom / lab content

| Path | Role |
|------|------|
| `docs/modules/` | AsciiDoc modules rendered by Showroom |
| Showroom chart values | Point content repo/path at this repository’s modules (see `docs/SHOWROOM-UPDATE-SPEC.md`) |

## What not to do

- Do not treat `examples/` as the long-term `gitops_path` for the published catalog item.
- Do not invent alternate LWN channel names; use Validated / Remediated / OSV (see DEVELOPMENT-PLAN.md).
- Do not commit registry credentials or customer engagement data (see [AGENTS.md](../AGENTS.md)).

## Related

- [DEVELOPMENT-PLAN.md](../DEVELOPMENT-PLAN.md) — phases and rhpds transfer note  
- [charts/README.md](../charts/README.md) — production chart layout status  
- [examples/helm/README.md](../examples/helm/README.md) — App-of-Apps reference  
- [examples/ansible/README.md](../examples/ansible/README.md) — Ansible Job reference  
