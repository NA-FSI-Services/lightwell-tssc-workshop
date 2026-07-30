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
| Repository conventions | [docs/repository-conventions.md](./docs/repository-conventions.md) |
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
├── charts/                 # PRODUCTION GitOps (gitops_path → charts/root-app)
│   ├── root-app/           # App-of-Apps (ArgoCD Applications)
│   └── components/         # rhdh, rhtas, rhtpa, rhacs, lightwell-repo, spring-boot-lw-poc, …
├── examples/
│   ├── helm/               # REFERENCE only: App-of-Apps pattern
│   └── ansible/            # REFERENCE only: ansible-runner Jobs
├── roles/
│   └── ocp4_workload_field_content/  # AgnosticD field-content workload role
├── docs/                   # Conventions, guides; lab AsciiDoc → docs/modules/
├── DEVELOPMENT-PLAN.md
├── AGENTS.md
└── README.md
```

**Helm App-of-Apps** is the primary path (`charts/`). **Ansible runner** is optional for logic Helm cannot express; follow `examples/ansible/` inside a component chart. Full rules: [docs/repository-conventions.md](./docs/repository-conventions.md).

During early development, use `examples/helm` as the structural reference while scaffolding production charts under `charts/`.

## Production mirror (rhpds)

Development happens in `NA-FSI-Services/lightwell-tssc-workshop`. After charts deploy cleanly and pass RHDP E2E validation, request a transfer or mirror to [`github.com/rhpds/lightwell-tssc-workshop`](https://github.com/rhpds/lightwell-tssc-workshop) via [#forum-demo-redhat-com](https://redhat.enterprise.slack.com/archives/C04N203SNUW), then point AgnosticV `gitops_repo` at the `rhpds` URL.

## Local development

```bash
git clone git@github.com:NA-FSI-Services/lightwell-tssc-workshop.git
cd lightwell-tssc-workshop

# One-time: install git pre-commit hooks (requires helm + pre-commit)
brew install helm pre-commit   # or equivalent
pre-commit install

# Production App-of-Apps (preferred)
cd charts/root-app
helm lint .
helm template lightwell . --set deployer.domain=apps.cluster.example.com

# Structural reference only
cd ../../examples/helm && helm template .
```

### Pre-commit (helm lint)

This repo uses [pre-commit](https://pre-commit.com) to run `helm lint` on charts under `charts/` before each commit (see [`.pre-commit-config.yaml`](./.pre-commit-config.yaml) and [`scripts/helm-lint.sh`](./scripts/helm-lint.sh)).

```bash
# After clone (once)
pre-commit install

# Run all hooks against the tree
pre-commit run --all-files

# Lint charts only (same script the hook uses)
./scripts/helm-lint.sh
```

Commits that change files under `charts/` will fail if `helm lint` fails. Ensure `helm` is on your `PATH`.

### CI (PRs to main)

Pull requests targeting `main` run [`.github/workflows/helm-validate.yml`](./.github/workflows/helm-validate.yml), which executes `helm lint` and `helm template` for every chart under `charts/` via [`scripts/helm-validate.sh`](./scripts/helm-validate.sh).

```bash
# Same checks as CI
./scripts/helm-validate.sh
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
- [docs/repository-conventions.md](./docs/repository-conventions.md) — Helm vs Ansible paths, bootstrap provenance  
- [AGENTS.md](./AGENTS.md) — rules for coding agents  
- [docs/ansible-developer-guide.md](./docs/ansible-developer-guide.md) — Ansible runner patterns  
- [docs/SHOWROOM-UPDATE-SPEC.md](./docs/SHOWROOM-UPDATE-SPEC.md) — Showroom maintenance  
- [examples/helm/README.md](./examples/helm/README.md) / [examples/ansible/README.md](./examples/ansible/README.md) — template examples  

## Channels

- [#forum-demo-redhat-com](https://redhat.enterprise.slack.com/archives/C04N203SNUW) — RHDP / catalog onboarding  
- [#forum-services-lightwell](https://redhat.enterprise.slack.com/archives/C0BEQN68BTN) — Lightwell services enablement  
