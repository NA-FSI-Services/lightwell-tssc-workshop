# Lightwell TSSC Workshop (RHDP)

RHDP catalog content for a hands-on **Lightwell Network + Trusted Software Supply Chain** workshop on [demo.redhat.com](https://demo.redhat.com).

Learners practice the same integration patterns used in Lightwell Network proof-of-value delivery: Validated and Remediated repositories, **Maven and PyPI** consumption via an enterprise artifact manager, OSV-driven exact-version pins (`.rhlw-*`), SBOM analysis, and TSSC pipeline controls. This catalog is **Java and Python**: Modules 1–6 (Java), then Modules 7–9 (FastAPI / PyPI — epic [#144](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/144)). PyPI Remediated is always enabled (seeded `.rhlw-*` marker).

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
4. Component charts deploy TSSC tooling, an LWN-shaped artifact repository (Maven + PyPI proxy or seeded mirrors), Spring Boot and FastAPI sample apps, and Showroom labs.

```
This Git repo                         OpenShift (RHDP / CNV)
┌──────────────────┐                 ┌──────────────────────────────────┐
│ charts/root-app  │─── ArgoCD ─────▶│ RHDH · RHTAS · RHTPA · RHACS     │
│ + components/*   │                 │ Artifact mgr (Maven + PyPI / OSV) │
│ docs/modules/    │                 │ Spring Boot · FastAPI · Showroom │
└──────────────────┘                 └──────────────────────────────────┘
```

## Workshop narrative (lab modules)

**Java (Modules 1–6 — complete first):**

1. Lightwell Network overview (Validated vs Remediated)
2. Enterprise integration: Maven settings and artifact-manager proxy (+ Gitea learner setup)
3. Scaffold with Developer Hub (`lightwell-java-service`)
4. OSV triage and exact-version remediation (`.rhlw-*` pin + source diff) — helpers in [`tools/osv-eval/`](./tools/osv-eval/)
5. SBOM generation and analysis with RHTPA ([RHDA shift-left](./docs/rhda-rhtpa-shift-left.md) on laptop; Showroom uses TPA UI/`syft`)
6. Pipeline signing, RHACS policy enforcement, and GitOps promotion

**Python (Modules 7–9 — required track; epic [#144](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/144)):**

7. PyPI Validated + FastAPI sample / Gitea seed
8. Remediated PyPI pin + SPDX/SBOM → RHTPA (`channels.pypiRemediated.enabled=true` always)
9. Pipeline signing, policy, and GitOps promote for the Python path

## Repository layout

```
lightwell-tssc-workshop/
├── charts/                 # PRODUCTION GitOps (gitops_path → charts/root-app)
│   ├── root-app/           # App-of-Apps (ArgoCD Applications)
│   └── components/         # rhdh, rhtas, rhtpa, rhacs, lightwell-repo, spring-boot-lw-poc, fastapi-lw-poc, …
├── agnosticv/              # STAGING AgnosticV drafts (catalog ID published.lightwell-tssc-workshop.prod)
├── examples/
│   ├── helm/               # REFERENCE only: App-of-Apps pattern
│   └── ansible/            # REFERENCE only: ansible-runner Jobs
├── roles/
│   └── ocp4_workload_field_content/  # AgnosticD field-content workload role
├── tools/osv-eval/         # Module 3 OSV pin + source-diff helpers
├── docs/                   # Antora labs (modules/ROOT) + conventions
├── site.yml                # Showroom Antora playbook
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
brew install helm pre-commit   # or equivalent; Node 20+ for local Antora CI parity
pre-commit install

# Production App-of-Apps (preferred)
cd charts/root-app
helm lint .
helm template lightwell . --set deployer.domain=apps.cluster.example.com

# Structural reference only
cd ../../examples/helm && helm template .
```

### Pre-commit

This repo uses [pre-commit](https://pre-commit.com) (see [`.pre-commit-config.yaml`](./.pre-commit-config.yaml)):

| Hook | When | Script |
|------|------|--------|
| `helm lint` | Changes under `charts/` | [`scripts/helm-lint.sh`](./scripts/helm-lint.sh) |
| AsciiDoc structural check | Changes under `docs/`, `site.yml`, `site-ci.yml` | [`scripts/asciidoc-check.sh`](./scripts/asciidoc-check.sh) |
| Learner Git decision | Showroom / seed overlays / RHDH catalog | [`scripts/learner-git-check.sh`](./scripts/learner-git-check.sh) |

```bash
# After clone (once)
pre-commit install

# Run all hooks against the tree
pre-commit run --all-files

# Same scripts the hooks use
./scripts/helm-lint.sh
./scripts/asciidoc-check.sh
```

Ensure `helm` is on your `PATH` for chart commits.

### CI (PRs to main)

| Workflow | What it runs |
|----------|----------------|
| [helm-validate.yml](./.github/workflows/helm-validate.yml) | `helm lint` + `helm template` for `charts/` ([`scripts/helm-validate.sh`](./scripts/helm-validate.sh)) |
| [antora-validate.yml](./.github/workflows/antora-validate.yml) | `asciidoc-check.sh` + lightweight Antora generate (`site-ci.yml`) when docs/playbooks change |

```bash
# Same checks as CI
./scripts/helm-validate.sh
./scripts/asciidoc-check.sh          # includes learner-git-check.sh
./scripts/learner-git-check.sh       # Gitea templates / no hardcoded lw-user1
npx --yes antora@3.1.10 site-ci.yml   # optional local Antora generate
```

Showroom continues to use [`site.yml`](./site.yml) (RHDP theme + extensions). CI uses [`site-ci.yml`](./site-ci.yml) without those extensions for a fast generate.

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
