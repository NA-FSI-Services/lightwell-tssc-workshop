# Lightwell TSSC Workshop (RHDP)

RHDP catalog content for a hands-on **Lightwell Network + Trusted Software Supply Chain** workshop on [demo.redhat.com](https://demo.redhat.com).

Learners practice the same integration patterns used in Lightwell Network proof-of-value delivery: Validated and Remediated repositories, Maven consumption (optionally via an enterprise artifact manager), OSV-driven exact-version pins (`.rhlw-*`), SBOM analysis, and TSSC pipeline controls.

## Purpose

This repository is the GitOps source for the workshop environment. It is **not** a generic field-content template; it implements the Lightwell workshop stack using the AgnosticD v2 **Field Sourced Content** pattern (`agd-v2.ocp-field-asset-cnv.prod`).

Bootstrapped from [rhpds/field-sourced-content-template](https://github.com/rhpds/field-sourced-content-template). Target catalog item: `published.lightwell-tssc-workshop.prod`.

## Tracking

| Resource | Link |
|----------|------|
| Development plan | [DEVELOPMENT-PLAN.md](./DEVELOPMENT-PLAN.md) |
| GitHub Project | [Lightwell TSSC Workshop](https://github.com/orgs/NA-FSI-Services/projects/1) |
| Agent rules | [AGENTS.md](./AGENTS.md) |

## How it works

1. An associate orders the workshop catalog item on RHDP.
2. AgnosticV resolves `agd-v2.ocp-field-asset-cnv.prod` and claims a pre-warmed OpenShift (CNV) cluster.
3. OpenShift GitOps (ArgoCD) syncs this repository (`charts/root-app`).
4. Component charts deploy TSSC tooling, an LWN-shaped artifact repository (proxy or seeded mirrors), a Spring Boot sample app, and Showroom labs.

```
This Git repo                         OpenShift (RHDP / CNV)
┌──────────────────┐                 ┌──────────────────────────────────┐
│ charts/root-app  │─── ArgoCD ─────▶│ RHDH · RHTAS · RHTPA · RHACS     │
│ + components/*   │                 │ Artifact mgr (validated/remediated/OSV) │
│ docs/modules/    │                 │ Spring Boot PoC · Showroom       │
└──────────────────┘                 └──────────────────────────────────┘
```

## Workshop narrative (lab modules)

1. AI vulnerability storm and Lightwell Network overview (Validated vs Remediated)
2. Enterprise integration: Maven settings and artifact-manager proxy
3. OSV triage and exact-version remediation (`.rhlw-*` pin + source diff)
4. SBOM generation and analysis with RHTPA (RHDA shift-left callout)
5. Pipeline signing, RHACS policy enforcement, and GitOps promotion

## Repository layout

```
lightwell-tssc-workshop/
├── charts/                 # Target: App-of-Apps + components (in progress)
│   ├── root-app/
│   └── components/         # rhdh, rhtas, rhtpa, rhacs, lightwell-repo, spring-boot-lw-poc, …
├── examples/
│   ├── helm/               # Template reference (field-sourced pattern)
│   └── ansible/            # Template reference (ansible-runner Jobs)
├── roles/
│   └── ocp4_workload_field_content/  # AgnosticD field-content workload role
├── docs/                   # Developer guides; lab AsciiDoc → docs/modules/
├── DEVELOPMENT-PLAN.md
├── AGENTS.md
└── README.md
```

During early development, use `examples/helm` as the structural reference while scaffolding production charts under `charts/`.

## Local development

```bash
git clone git@github.com:NA-FSI-Services/lightwell-tssc-workshop.git
cd lightwell-tssc-workshop

# Inspect the field-content Helm example
cd examples/helm
helm template .   # once charts/root-app exists, prefer that path
```

Order a Field Content / agd-v2 field-asset CNV catalog item pointing at this repository for cluster-based validation. Full RHDP onboarding steps are in [DEVELOPMENT-PLAN.md](./DEVELOPMENT-PLAN.md).

## RHDP integration labels

```yaml
# Health monitoring
metadata:
  labels:
    demo.redhat.com/application: "lightwell-tssc-workshop"

# Pass URLs / credentials back to AgnosticD
metadata:
  labels:
    demo.redhat.com/userinfo: ""
```

## Documentation

- [DEVELOPMENT-PLAN.md](./DEVELOPMENT-PLAN.md) — phases, LWN lab model, issue map  
- [AGENTS.md](./AGENTS.md) — rules for coding agents  
- [docs/ansible-developer-guide.md](./docs/ansible-developer-guide.md) — Ansible runner patterns  
- [docs/SHOWROOM-UPDATE-SPEC.md](./docs/SHOWROOM-UPDATE-SPEC.md) — Showroom maintenance  
- [examples/helm/README.md](./examples/helm/README.md) / [examples/ansible/README.md](./examples/ansible/README.md) — template examples  

## Channels

- [#forum-demo-redhat-com](https://redhat.enterprise.slack.com/archives/C04N203SNUW) — RHDP / catalog onboarding  
- [#forum-services-lightwell](https://redhat.enterprise.slack.com/archives/C0BEQN68BTN) — Lightwell services enablement  
