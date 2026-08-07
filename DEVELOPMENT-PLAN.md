# Lightwell TSSC Workshop — Development Plan

This repository delivers a **Red Hat Demo Platform (RHDP)** workshop that demonstrates Lightwell Network (LWN) consumption and exact-version remediation, integrated with Red Hat Trusted Software Supply Chain tooling.

## Tracking

| Resource | Link |
|----------|------|
| GitHub Project | [Lightwell TSSC Workshop](https://github.com/orgs/NA-FSI-Services/projects/1) |
| Issues | [NA-FSI-Services/lightwell-tssc-workshop/issues](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues) |
| Repository | [NA-FSI-Services/lightwell-tssc-workshop](https://github.com/NA-FSI-Services/lightwell-tssc-workshop) |
| Source template | [rhpds/field-sourced-content-template](https://github.com/rhpds/field-sourced-content-template) |
| Target catalog ID | `published.lightwell-tssc-workshop.prod` |
| Environment type | `agd-v2.ocp-field-asset-cnv.prod` |

Source planning documents:

- *Architecture and Execution Strategy: Onboarding the Lightwell Workshop Environment to the Red Hat Demo Platform*
- Field services engagement patterns (Proof of Value delivery) — used to align lab steps with real LWN integration (no customer-specific details retained here)

## Goal

Hands-on workshop showing:

- Lightwell Network **Validated** vs **Remediated** repository tiers
- Enterprise consumption via Maven (and optional enterprise artifact-manager proxy)
- Exact-version remediations using the `.rhlw-0000X` version suffix
- OSV-driven vulnerability triage for remediated Java artifacts
- SBOM generation (CycloneDX) and analysis in Red Hat Trusted Profile Analyzer (RHTPA)
- Optional shift-left via Red Hat Dependency Analytics (RHDA) against RHTPA
- Keyless signing / SLSA provenance with Red Hat Trusted Artifact Signer (RHTAS)
- Policy gating with Red Hat Advanced Cluster Security (RHACS)
- Developer golden paths via Red Hat Developer Hub (RHDH)
- GitOps promotion with OpenShift GitOps (ArgoCD)
- **Python path** (Modules 7–9, epic [#144](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/144) **complete**): PyPI Validated + Remediated (always seeded on), FastAPI sample, SPDX/SBOM → RHTPA, pipeline / sign / policy / GitOps — catalog is **Java and Python**

Provisioned through AgnosticD v2 **GitOps Field Sourced Content** on OpenShift Virtualization (CNV) pools (~10–15 minute claim + sync).

## Lab model aligned to field PoV delivery

The workshop must simulate the same technical story used in Lightwell Network introduction / PoV engagements—not a fictional “untrusted vs secured” rename.

### Lightwell Network repository model (authoritative)

| Tier | Purpose | Typical URL | Learner outcome |
|------|---------|-------------|-----------------|
| **Validated** (Java) | Upstream-parity rebuilds of current libraries; no app code changes | `https://packages.redhat.com/lightwell/java/validated` | Trust upstream for active development |
| **Remediated** (Java) | Exact-version backports for pinned production deps | `https://packages.redhat.com/lightwell/java/remediated` | Fix CVEs without risky major upgrades |
| **OSV (Java)** | Machine-readable fixed-vuln records for remediated stream | `https://packages.redhat.com/lightwell/osv/java/remediated` | Discover *what* was fixed and *which* `.rhlw-*` version to pin |
| **Validated** (Python / PyPI) | Upstream-parity rebuilds for `pip` / enterprise PyPI proxy | `https://packages.redhat.com/lightwell/python/validated` | Modules 7–9 Validated consumption |
| **Remediated** (Python / PyPI) | Exact-version remediations (workshop always seeds marker) | `https://packages.redhat.com/lightwell/python/remediated`; **require** `channels.pypiRemediated.enabled=true` (seeded `.rhlw-*` marker) | Module 8 |

Remediated artifact versions append a sequential Lightwell suffix, for example `5.3.18.rhlw-00003` (not a custom `-lw01` naming scheme).

Artifacts ship with supply-chain metadata:

- SBOM (Java: CycloneDX beside the JAR; Python wheels: SPDX under `*.dist-info/sboms/`)
- SLSA Level 3 build provenance / signed binaries (Sigstore family)
- OSV records for remediated Java; traditional VEX/CSAF remains complementary / roadmap-aware in content

UI reference for members: [console.redhat.com/lightwell](https://console.redhat.com/lightwell). Auth uses Red Hat registry service accounts ([terms-based registry](https://access.redhat.com/terms-based-registry/)) exposed to build tools as `LW_USERNAME` / `LW_PASSWORD` (or RHDP-injected equivalents). **Never commit credentials.**

### Enterprise consumption pattern

PoV delivery almost always includes an **enterprise artifact manager** (Artifactory or Nexus) that remotes/proxies LWN, plus client config:

- **Java / Maven:** Direct `lightwell-validated` + `lightwell-remediated` profiles pointing at `packages.redhat.com`, or proxied via internal `libs-release` (etc.) with remotes for validated/remediated (and optionally OSV)
- **Python / PyPI:** `pip` index URL (and/or Nexus/Artifactory **PyPI** proxy) aimed at Lightwell **Validated**, then **Remediated** (this workshop always enables Remediated with a seeded marker)

RHDP lab implication: `charts/components/lightwell-repo` should present that enterprise pattern (Nexus or Artifactory). Prefer either:

1. **Live proxy** to LWN when workshop credentials/membership allow, or  
2. **Seeded mirrors** of a small curated set of validated + remediated **Java** artifacts and sample OSV JSON, plus **PyPI Validated and Remediated** packages for Modules 7–9  

Either way, naming, URLs (or documented remote targets), and Java `.rhlw-*` semantics must match production LWN. Do not invent fictional channel aliases.

### Primary sample applications (Java first, then Python)

**Java (Modules 1–6):** a **small Spring Boot / Java 17 / Maven** service (greeting API + OpenAPI), demonstrating:

- Dual dependency streams (validated + remediated pins in `pom.xml`)
- `mvn -s settings.xml clean verify` / `spring-boot:run`
- SBOM generation with `syft` → CycloneDX JSON
- Source compare of upstream vs `.rhlw-*` jars to show minimal backport impact

**Python (Modules 7–9):** a minimal **FastAPI** service after the Java path (epic [#144](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/144)) — catalog is Java **and** Python:

- Condensed beats: **7** PyPI Validated + Gitea seed · **8** Remediated pin + SPDX/SBOM → RHTPA · **9** pipeline / sign / policy / GitOps
- **Always** keep `channels.pypiRemediated.enabled=true` and seed the workshop `.rhlw-*` marker (do not disable Remediated PyPI for catalog claims)
- Learner remotes remain Gitea (`workshop-templates` → `lw-<username>`) — same bans as Java

Parasol (or similar multi-tier demo app) remains optional reuse for a larger “enterprise app” narrative after the Spring Boot PoC path works.

### Remediation evaluation loop (must be a lab beat)

Reproduce the PoV proof steps learners need in the field:

1. Inspect an OSV file from the Java remediated OSV repo  
2. Read `affected[].ranges[].events[].fixed` → target `.rhlw-*` version  
3. Download sources for base and remediated artifacts  
4. `diff` sources to show scoped security backport  
5. Update `pom.xml` to the remediated version and rebuild  

Optional advanced / instructor note: poll OSV `PULP_MANIFEST` (Ansible/AAP-style) to detect new OSV files and trigger ticket/pipeline actions—teach the automation implication without binding to any customer ITSM.

### TSSC platform tools (engagement forward path)

Keep RHTPA as the SBOM system of record; call out RHDA as the IDE shift-left client of RHTPA. Retain RHTAS + RHACS + RHDH + GitOps for the automated supply-chain half of the workshop.

## Architecture summary

```
RHDP order (demo.redhat.com)
        │
        ▼
AgnosticV → agd-v2.ocp-field-asset-cnv.prod
        │
        ▼
Claim pre-warmed OCP (CNV) + bootstrap OpenShift GitOps
        │
        ▼
ArgoCD syncs this repo → charts/root-app (App of Apps)
        │
        ├── rhdh (+ lightwell-java-service; lightwell-python-service for Modules 7–9)
        ├── rhtas
        ├── rhtpa (+ RHDA-oriented APIs)
        ├── rhacs
        ├── lightwell-repo (Maven + PyPI: validated / remediated / Java OSV)
        ├── spring-boot-lw-poc (Java primary) · fastapi-lw-poc (Python, #146)
        ├── optional parasol-app
        └── showroom + AsciiDoc modules (1–6 Java, then 7–9 Python)
```

### Reuse from existing catalog items

| Source catalog | Reuse |
|----------------|-------|
| RHADS Demo (`enterprise.redhat-ads-demo.prod` / `pert.redhat-rhads.prod`) | RHDH, RHTPA, RHTAS operator/Helm patterns |
| Trusted Software Factory (`agd-v2.trusted-software-factory-cnv.prod`) | Keyless signing (Fulcio/Rekor/TUF), SLSA tasks, SBOM → RHTPA |
| RHACS Demo (`agd-v2.rhacs-demo-cnv.prod`) | `roxctl` Tekton tasks and policy patterns (OSV-friendly scanners) |
| OpenShift Dev Day Roadshow (`published.ocp-dev-days-rdshw.prod`) | Optional Parasol multi-tier workload |
| Field PoV sample patterns | Spring Boot Maven LWN integration, settings profiles, OSV/source-diff narrative |

## Phased delivery

Issues are labeled `phase-1` … `phase-5` and tracked on the [GitHub Project](https://github.com/orgs/NA-FSI-Services/projects/1).

### Phase 1 — Bootstrap and repository engineering

Issues: [#1](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/1)–[#8](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/8), [#24](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/24)

- Adopt field-sourced content template layout ([docs/repository-conventions.md](./docs/repository-conventions.md))
- Scaffold `charts/root-app` App-of-Apps
- Component charts: `rhdh`, `rhtas`, `rhtpa`, `rhacs`, `lightwell-repo`, `spring-boot-lw-poc` (Java primary), `fastapi-lw-poc` (Python, [#146](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/146)), optional `parasol-app`
- After E2E success, request mirror/transfer to `github.com/rhpds/lightwell-tssc-workshop` (see [Production mirror plan](#production-mirror-plan-rhpds) below)

### Production mirror plan (rhpds)

| Stage | Repository | Notes |
|-------|------------|-------|
| Now | `github.com/NA-FSI-Services/lightwell-tssc-workshop` | Prototyping and Phase 1–4 development |
| After E2E on RHDP | Request transfer/mirror via [#forum-demo-redhat-com](https://redhat.enterprise.slack.com/archives/C04N203SNUW) | Content team / RHDP maintainers |
| Published catalog | `github.com/rhpds/lightwell-tssc-workshop` | Update AgnosticV `user_data.gitops_repo` to the `rhpds` URL |

Until the mirror exists, AgnosticV drafts and Field Content CI orders may point at the `NA-FSI-Services` URL with `gitops_path: charts/root-app`.

### Phase 2 — AgnosticV and infrastructure sizing

Issues: [#9](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/9)–[#10](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/10)

- Draft AgnosticV leaves for [`redhat-cop/agnosticv`](https://github.com/redhat-cop/agnosticv) — **in-repo staging:** [`agnosticv/`](./agnosticv/) (issue #9; reshape #71); submit **dev-first** then prod (#20 ladder)
- Target pool: `agd-v2/ocp-virt-labs-pool`

- **Validated sizing** (issue #10 — see [`agnosticv/README.md`](./agnosticv/README.md)):
  - Control plane: 1× 16 vCPU / 32 GB RAM (meets RHADS-SSC recommended CP)
  - Workers: 2× 16 vCPU / 64 GB RAM each (above RHADS-SSC recommended 8/24 for Tekton + RHACS headroom)
  - Shape: multi-node only (not SNO); ~32 vCPU / ~128 GiB worker capacity
  - Memory pressure: concurrent Tekton PipelineRuns + RHACS Scanner/`roxctl` are the primary risk — limit pipeline concurrency on a shared claim
- Draft `user_data` (update repo URL when mirrored to `rhpds`):

```yaml
user_data:
  gitops_repo: "https://github.com/NA-FSI-Services/lightwell-tssc-workshop.git"
  gitops_path: "charts/root-app"
  gitops_revision: "main"
lifespan:
  default: 48h
  maximum: 180d
  idle_stop: 6h
```

### Phase 3 — Workload integration and Lightwell automation

Issues: [#11](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/11)–[#13](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/13), [#25](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/25)–[#26](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/26); Python track charts: [#145](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/145)–[#149](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/149) (**done**; epic [#144](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/144))

1. **Artifact manager channels** matching LWN: Java `validated` / `remediated` / `osv/remediated`, plus **PyPI Validated and Remediated** — see [`charts/components/lightwell-repo`](./charts/components/lightwell-repo/) (`seeded` default vs `proxy` with `LW_*`; Job seeds `spring-core` / `commons-lang3` + OSV path `osv/java/remediated/` + CycloneDX; PyPI hosts `httpx` Validated + `.rhlw-*` Remediated marker — [#145](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/145); **`channels.pypiRemediated.enabled` must stay `true`**)
2. **Spring Boot PoC** with Maven profiles, dual streams, and `.rhlw-*` pins
3. **Student Git (Gitea)** — learners clone/push only in-cluster Gitea; never GitHub for app labs. Seed Jobs isolate monorepo app paths into template remotes under `workshop-templates`; learners create `lw-<username>` and seed (Module 2 Java; Module 7 Python). ApplicationSet syncs gitops remotes into runtime namespaces ([`charts/components/gitea`](./charts/components/gitea/), [AGENTS.md](./AGENTS.md) Learner Git; Python templates #147)
4. **RHDH golden paths**: `lightwell-java-service` (Modules 2–6) and `lightwell-python-service` (Modules 7–9, #148) — `publish:gitea` into learner orgs; fetch templates from `workshop-templates` (not GitHub)
5. **OSV → pin → rebuild** automation-friendly steps — toolkit in [`tools/osv-eval/`](./tools/osv-eval/) (sample OSV, source-diff scripts, optional `PULP_MANIFEST` poll)
6. **RHACS gates** / pipeline checks that prefer remediated pins ([`charts/components/rhacs`](./charts/components/rhacs/) — `lightwell-dep-gate` + `roxctl image check` + `syft-sbom-rhtpa`); SBOM attestations land in RHTPA; Python pipeline / `.tekton` in #149
7. **FastAPI PoC** (`fastapi-lw-poc`, #146) — minimal app + thin GitOps chart for Modules 7–9

### Phase 4 — Lab content and Showroom

Issues: [#14](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/14)–[#19](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/19), [#27](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/27); Python modules / docs / visuals: [#150](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/150)–[#154](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/154) (**done**; epic [#144](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/144) complete; docs hygiene #153)

AsciiDoc under `docs/modules/ROOT/pages/` (Antora component + root `site.yml`), rendered in Showroom via [`charts/components/showroom`](./charts/components/showroom/) (wave 50; `showroom_url` userinfo).

**Java golden path (complete first):**

| Module | Title | PoV alignment |
|--------|-------|---------------|
| 1 | Lightwell Network overview | Validated vs Remediated; console; SLSA/SBOM/OSV |
| 2 | Maven + artifact manager | `settings.xml`, service account auth, validated/remediated consumption; Gitea learner setup |
| 3 | Scaffold with Developer Hub | RHDH `lightwell-java-service` → Gitea |
| 4 | OSV triage + `.rhlw-*` pins | OSV file → pin → source diff → rebuild |
| 5 | SBOM + RHTPA | `syft` CycloneDX → RHTPA; RHDA shift-left on laptop — [docs/rhda-rhtpa-shift-left.md](./docs/rhda-rhtpa-shift-left.md) |
| 6 | Sign, policy, GitOps | Tekton + RHTAS + RHACS + ArgoCD |

**Python path (after Java; condensed):**

| Module | Title | PoV alignment |
|--------|-------|---------------|
| 7 | PyPI Validated + FastAPI / Gitea | `pip` / Nexus PyPI proxy; seed from `workshop-templates` (#150) |
| 8 | Remediated PyPI pin + SPDX → RHTPA | Always-on Remediated channel (seeded marker); wheel SPDX vs Maven CycloneDX (#151) |
| 9 | Pipeline, sign, policy, GitOps | Python Tasks / `.tekton`; promote learner gitops (#152) |

Python figures (#154) and docs hygiene (#153) are committed under `docs/modules/ROOT/`. Epic [#144](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/144) (chart + content children #145–#154) is complete; catalog remains Java **and** Python.

### Phase 5 — Testing, QA, and production launch

**AgnosticV target:** [`redhat-cop/agnosticv`](https://github.com/redhat-cop/agnosticv) (Babylon-documented). **Strategy:** dev-first → prod. Checklist: [`agnosticv/SUBMISSION.md`](./agnosticv/SUBMISSION.md).

**RHDP catalog intake form:** [https://red.ht/demo-onboarding](https://red.ht/demo-onboarding) — field answers and Showroom notes recorded in [`agnosticv/SUBMISSION.md`](./agnosticv/SUBMISSION.md#rhdp-demo--lab-onboarding-form) (no requester PII).

**While AgnosticV access is blocked:** order a demo.redhat.com OpenShift claim, fill `dev-cluster/claim.env` from the email, and run [`scripts/dev-cluster-bootstrap.sh`](./scripts/dev-cluster-bootstrap.sh) — see [`docs/DEV-CLUSTER-BOOTSTRAP.md`](./docs/DEV-CLUSTER-BOOTSTRAP.md). That path is for instruction/GitOps QA only; it does not replace catalog onboarding. Do not commit ephemeral claim hostnames or credentials.

| Step | Issue | Outcome |
|------|-------|---------|
| Umbrella | [#20](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/20) | AgnosticV onboarding tracker |
| Reshape draft | [#71](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/71) | Folder leaf under [`agnosticv/lightwell-tssc-workshop/`](./agnosticv/lightwell-tssc-workshop/) |
| UUID / schema | [#72](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/72) | `46fb0d02-…c7d5` + [`scripts/agnosticv-check.sh`](./scripts/agnosticv-check.sh) |
| DEV PR | [#73](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/73) | PR to `redhat-cop/agnosticv` with DEV stage |
| DEV validate | [#21](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/21) | Order on `babylon-catalog-dev`; claim, Showroom, GitOps |
| Prod promote | [#22](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/22) | `prod.yaml` + production CatalogItem (`published.lightwell-tssc-workshop.prod`) |
| Enablement | [#23](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/23) | Sales Hub + forum announcements |

GitOps (all stages): `https://github.com/NA-FSI-Services/lightwell-tssc-workshop.git` → `charts/root-app` @ `main`. Human confirmation required before upstream AgV PRs ([AGENTS.md](./AGENTS.md)).

## Works cited

- [RHDP demo / lab onboarding](https://red.ht/demo-onboarding)
- [RHDP Catalog Item Matrix](https://drive.google.com/a/redhat.com/open?id=1YUZ_xcJtffFDKXo0rsb4W38QlcD-JI9AFSHdToRbIbg)
- [Kickoff: Lightwell (LW) Targeted Enablement Curation](https://drive.google.com/a/redhat.com/open?id=1cOMdKJnb5izWO2bqEM5fkgX7n078fwulrM0F0zpOeXI)
- [Red Hat Lightwell Network docs — configure Artifactory](https://docs.redhat.com/en/documentation/red_hat_lightwell_network/current/configure-configure_artifactory_to_use_rhln_repository)
- [Lightwell console](https://console.redhat.com/lightwell)

## Agent guidance

See [AGENTS.md](./AGENTS.md) for rules agents must follow when contributing to this repository.
