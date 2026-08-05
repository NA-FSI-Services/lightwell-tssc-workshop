# AGENTS.md — Development rules for coding agents

This repository builds an **RHDP Lightwell Network + Trusted Software Supply Chain workshop**. Agents must optimize for repeatable GitOps demos on `agd-v2.ocp-field-asset-cnv.prod`, not for a general-purpose application product.

Read [DEVELOPMENT-PLAN.md](./DEVELOPMENT-PLAN.md) and [README.md](./README.md) before making structural changes. Track work against the [GitHub Project](https://github.com/orgs/NA-FSI-Services/projects/1) and labeled issues (`phase-1` … `phase-5`).

## Mission constraints

1. **Catalog item first** — Changes must support ordering, syncing, and teaching the Lightwell Network narrative on demo.redhat.com.
2. **Field-sourced GitOps** — Prefer Helm charts synced by ArgoCD. Use ansible-runner Jobs only when Helm cannot express wait/secret/API logic.
3. **Reuse over reinvent** — Adapt patterns from RHADS, Trusted Software Factory, RHACS demo, Dev Day / Parasol, and field PoV Spring Boot samples before inventing new operators or apps.
4. **Authoritative LWN model** — Use **Validated** and **Remediated** tiers (plus Java **OSV** for remediated). Do **not** invent alternate channel names such as `upstream-untrusted` / `lightwell-network-secured`.
5. **Exact-version suffix** — Remediated versions use `.rhlw-0000X` (e.g. `5.3.18.rhlw-00003`). Do not invent `-lw01` style suffixes.
6. **No customer PII** — Never commit or rewrite into docs any customer names, people, emails, internal tool names, tickets, or credentials from engagement reports.

## Preferred architecture

| Concern | Rule |
|---------|------|
| Layout | App-of-Apps under `charts/root-app`; components under `charts/components/<name>` — see [docs/repository-conventions.md](./docs/repository-conventions.md) |
| Examples | Treat `examples/helm` and `examples/ansible` as reference only; production content lives in `charts/` |
| Labs | AsciiDoc in `docs/modules/`; Showroom-compatible; one module per lab story beat |
| AgnosticV | Document drafts in-repo; do not invent catalog IDs—use `published.lightwell-tssc-workshop.prod` |
| OCP target | OpenShift 4.20-class CNV pool; multi-node sizing validated in `agnosticv/README.md` (1×16/32 CP + 2×16/64 workers) for RHDH + RHTAS + RHTPA + RHACS + Pipelines |
| Primary app | Spring Boot / Java 17 / Maven PoC with dual LWN streams (Modules 1–6); Parasol optional |
| Python | Post-Java critical path Modules 7–9 (FastAPI, epic #144); design for Remediated PyPI but **seed/gate** — do not block the Java catalog if live remediated is unavailable |

### Component ownership (do not collapse)

- `keycloak` — Workshop IdP for RHTPA (`sso.<domain>/realms/tpa`; enable before `rhtpa`)
- `pipelines` — OpenShift Pipelines (Tekton) Operator; enable before `rhacs` Module 6 / Module 9 Tasks / student `.tekton`
- `gitea` — In-cluster student Git; Module 6 / Module 9 pipeline labs use learner repos (not the GitOps monorepo)
- `rhdh` — Developer Hub + `lightwell-java-service` (and `lightwell-python-service` for Modules 7–9; #148); scaffold may land in Gitea
- `rhtas` — Trusted Artifact Signer / keyless signing 
- `rhtpa` — SBOM (and advisory) ingestion/analysis; RHDA consumes its APIs 
- `rhacs` — Central + pipeline / admission policy gates 
- `lightwell-repo` — Enterprise artifact manager (Maven + PyPI validated / remediated / Java OSV proxy or seeded mirrors; PyPI in #145) 
- `spring-boot-lw-poc` — Primary Java sample app for Maven + LWN labs 
- `fastapi-lw-poc` — Python FastAPI sample for Modules 7–9 (#146)
- `parasol-app` — Optional larger enterprise workload

### Learner Git — Gitea first (do not send students to GitHub)

Students must **not** be directed to clone, fork, or push to GitHub for lab application work. Prefer in-cluster **Gitea** (`charts/components/gitea`) for all learner remotes, PipelineRun `repo-url` values, Software Template outputs, and Showroom copy-paste steps.

#### Decision (install vs learner steps) — issue #120

| Phase | Who | What |
|-------|-----|------|
| **Install / seed Job** | Operator | Start Gitea; create student **users**; publish public org **`workshop-templates`** with public template repos (app, gitops, RHDH skeleton) isolated from the monorepo |
| **Module 2** | Learner | Create org **`lw-<username>`** + empty Java repos; run `learner-seed-from-templates.sh` (from ConfigMap) to copy templates into their remotes |
| **Modules 3–6** | Learner | Use `student_repo_url` / placeholders (`STUDENT_REPO_URL_PLACEHOLDER`); RHDH publishes into **`lw-<username>`** |
| **Modules 7–9** | Learner | Same org; Python app/gitops remotes from `workshop-templates` (seed #147); RHDH `lightwell-python-service` when available (#148) |

**Hard bans for Showroom / learner instructions:** never paste `https://github.com/NA-FSI-Services/lightwell-tssc-workshop.git` (or any GitHub clone of this monorepo) into Modules 1–9, Software Templates, or PipelineRun examples aimed at students. That URL is for **operators / GitOps / seed Jobs only**. If a lab needs application sources, point learners at **their** Gitea remotes (`lw-<username>/spring-boot-lw-poc` or the Python FastAPI remote, URLs from `demo-userinfo-gitea`), seeded from in-cluster `workshop-templates` (never GitHub).

**Never hardcode** `lw-user1` / `user1` in seeded `.tekton` overlays or shared lab YAML — use `STUDENT_REPO_URL_PLACEHOLDER` and Showroom / `oc` substitution from `demo-userinfo-gitea`.

| Audience | Git surface |
|----------|-------------|
| **Learners** | Gitea only — charts start Gitea + user accounts; learners **create** org `lw-<username>` and repos, then seed from `workshop-templates` (Module 2). Discover URLs via `demo-userinfo-gitea` (`gitea_url`, `student_gitea_org`, `student_repo_url`, `student_gitops_repo_url`, `template_*`, credentials). App work clones **`student_repo_url`** (contents at **repo root**). |
| **Operators / GitOps** | This workshop monorepo on GitHub (ArgoCD sync source for platform charts) — never presented as the student app or student runtime remote |
| **Authors / agents** | May read monorepo paths on GitHub when building charts; seed Jobs isolate learner-facing trees into Gitea |

**Path isolation when the app lives under a monorepo subdirectory** (e.g. `charts/components/spring-boot-lw-poc/app`, or `charts/components/fastapi-lw-poc/app` when added):

1. Provision-time automation (Gitea seed Job, ansible-runner, or equivalent) clones the **workshop** Git source (GitHub or the synced checkout).
2. Extracts **only** the intended application subtree (and any files that must sit at repo root for labs, such as `pom.xml` / `requirements.txt` / `pyproject.toml`, `Dockerfile`, `.tekton/`, and Module 4 `tools/osv-eval/` when needed).
3. Creates / updates **template** remotes under Gitea org **`workshop-templates`** with **that isolated tree at repository root** (not nested under `charts/components/...`). Learners do **not** receive auto-created app repos.
4. Optionally prepares a separate **gitops** template (`workshop-templates/gitops-spring-boot-lw-poc`, and the Python gitops twin from #147) with the thin Helm chart (same component path **minus** `./app`) for Argo CD runtime promote (Module 6 / Module 9).
5. Learners create org **`lw-<username>`** + empty repos, then run `learner-seed-from-templates.sh` (Showroom Module 2 / Module 7) to push template content into their remotes. RHDH `publish:gitea` later targets that learner Organization. Prefer RHDH `fetch:template` from **`workshop-templates/lightwell-java-service`** or **`workshop-templates/lightwell-python-service`** (not GitHub) once seeded.
6. Does **not** expose AgnosticV, other components, secrets, or the rest of the monorepo in student remotes.

**Agent enforcement:** Cursor rules under `.cursor/rules/` (`learner-git-gitea.mdc`, `showroom-learner-git.mdc`, `gitea-seed-overlays.mdc`, `rhdh-scaffolder-gitea.mdc`). Local check: `./scripts/learner-git-check.sh`.

Lab modules, PipelineRuns, and RHDH templates must clone **`student_repo_url`** (or the per-user URL under `student_repos`) for app work, and **`student_gitops_repo_url`** for digest promote — never `github.com/NA-FSI-Services/lightwell-tssc-workshop` (or any GitHub app URL) as the learner workflow. Do **not** ask students to `cd charts/components/spring-boot-lw-poc/app` inside a monorepo checkout.

When adding a new learner application source that currently lives at `/some/inner/path` in this repo, update the Gitea seed (or add a prepare Job) to perform isolation — do not ask students to `cd` into a monorepo path or clone GitHub.

### Canonical LWN endpoints (document even when mirroring)

- Java validated: `https://packages.redhat.com/lightwell/java/validated`
- Java remediated: `https://packages.redhat.com/lightwell/java/remediated`
- Java OSV remediated: `https://packages.redhat.com/lightwell/osv/java/remediated`
- Python / PyPI validated: `https://packages.redhat.com/lightwell/python/validated` (pip simple: `…/simple`)
- Python / PyPI remediated: `https://packages.redhat.com/lightwell/python/remediated` (pip simple: `…/simple`; gate via `channels.pypiRemediated.enabled` when live unavailable — see [#145](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/145))
- Console: `https://console.redhat.com/lightwell`

## Coding standards

- Match existing Helm/Ansible style in this repo and the field-sourced template.
- Use ArgoCD sync waves for operator → config → app → showroom ordering.
- Label health and userinfo resources for RHDP:

  ```yaml
  demo.redhat.com/application: "lightwell-tssc-workshop"
  demo.redhat.com/userinfo: ""
  ```

- AgnosticD variables keep the `ocp4_workload_` prefix when touching the field-content role.
- Prefer declarative manifests; avoid one-off cluster state that cannot be recreated from Git.
- Do not commit secrets, registry service-account tokens, vault ciphertext, or customer data. Use env placeholders (`LW_USERNAME` / `LW_PASSWORD`) and RHDP secret injection docs.
- Maven learner UX should support `mvn -s settings.xml …` with validated + remediated profiles.
- Python learner UX should support `pip` (or equivalent) against the workshop Nexus / Lightwell PyPI index URL once #145 lands.
- Do not expand scope into unrelated template cleanup, drive-by refactors, or new markdown docs unless requested or required for the task.

## Lab / Showroom content rules

- Modules must teach: (1) validated vs remediated, (2) enterprise Maven/proxy setup, (3) OSV → `.rhlw-*` pin + source diff, (4) SBOM → RHTPA, (5) pipeline/signing/policy/GitOps; then Modules 7–9 for the Python parallel (PyPI Validated, remediated-when-available, SPDX/SBOM, pipeline/GitOps — epic #144).
- Prefer deterministic seeded artifacts when live LWN membership is unavailable in RHDP.
- Prefer copy-pasteable `oc` / `tkn` / `mvn` / `pip` / `syft` paths that match deployed chart names and namespaces.
- **Learner remotes are Gitea** — do not document GitHub clone/fork/push for student app labs; use `demo-userinfo-gitea` and path-isolated templates → learner orgs (see **Learner Git** above). Never stage Module 2–9 PoC work from a `git clone` of this monorepo; use Gitea `lw-<username>/…` remotes with build metadata at clone root (`pom.xml` or `requirements.txt` / `pyproject.toml`).
- Update Showroom image/chart pins per [docs/SHOWROOM-UPDATE-SPEC.md](./docs/SHOWROOM-UPDATE-SPEC.md) when touching Showroom.
- **Lab visuals (images)** — When authoring or revising AsciiDoc labs, evaluate where a figure would clarify a concept (architecture, UI orientation, before/after, tier comparison). For each useful figure that is not already in-repo:
  1. Open a GitHub issue (`phase-4` + `content`) that explains **how to obtain the asset**: either concrete **screenshot steps** (product URL, click path, what to crop/redact) **or** an **image-generation prompt** for an agent/designer (style, labels, must-include LWN tier names / `.rhlw-*`, must-avoid fictional channel names).
  2. In the AsciiDoc, add an **image placeholder** note that names the intended file under `docs/modules/ROOT/images/` and links to that issue (do not invent binary assets or commit customer screenshots with PII).
  3. When the asset is ready, replace the placeholder with a real `image::…` macro and close the issue.

## Git and issue hygiene

- Align commits and PRs with a project issue when one exists; reference `Fixes #N` or `Refs #N`.
- Prefer small PRs per component chart or lab module over monolith merges.
- Do not force-push shared branches, amend published history, or skip hooks unless a human explicitly requests it.
- Do not push or open PRs to [`redhat-cop/agnosticv`](https://github.com/redhat-cop/agnosticv) (Phase 5 AgnosticV target) or request `rhpds/` org transfer without human confirmation. Prefer **dev-first** (`dev.yaml` → `babylon-catalog-dev`) then **prod** (`prod.yaml`); see [`agnosticv/SUBMISSION.md`](./agnosticv/SUBMISSION.md).

## Validation expectations

Before claiming a chart or module done:

1. `helm template` (or equivalent) succeeds for touched charts.
2. Sync wave / dependency order is documented in values or chart README.
3. Acceptance criteria on the linked GitHub issue are addressed or explicitly deferred with a follow-up issue.
4. For cluster work: ArgoCD Application reaches Healthy/Synced; Showroom renders module content when content changed.
5. For LWN content: channel names, `.rhlw-*` examples, and OSV steps match [DEVELOPMENT-PLAN.md](./DEVELOPMENT-PLAN.md).

## Out of scope for agents (unless asked)

- Changing RHDP global platform behavior or AgnosticD core roles outside this repo’s field-content role
- Pricing, commercial Lightwell tier claims, or Salesforce workflow
- Replacing Lightwell with a different remediation product narrative
- Embedding customer engagement details, org charts, or proprietary process names
- Broad rewrites of the upstream field-sourced template examples unrelated to Lightwell

## When uncertain

Prefer the smallest change that advances the current phase issue. Ask the human before altering catalog IDs, pool selection, cluster sizing, org-level repository transfer plans, or whether labs use live LWN vs seeded mirrors.

## Dev-cluster QA (agents)

When provisioning an ephemeral claim via [`scripts/dev-cluster-bootstrap.sh`](./scripts/dev-cluster-bootstrap.sh):

- Expect a single Gitea learner **`user1`** with a **generated password** printed in the bootstrap banner.
- Capture that password for Module 5 / Gitea / promote tests; details in [`docs/DEV-CLUSTER-WORKSHOP-USER.md`](./docs/DEV-CLUSTER-WORKSHOP-USER.md).
- Do not commit `dev-cluster/claim.env` or `dev-cluster/workshop-user.env`.
