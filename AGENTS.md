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
| Primary app | Spring Boot / Java 17 / Maven PoC with dual LWN streams; Parasol optional |
| Python | Validated-only secondary path; do not block the catalog on remediated PyPI |

### Component ownership (do not collapse)

- `rhdh` — Developer Hub + `lightwell-java-service` Software Template  
- `rhtas` — Trusted Artifact Signer / keyless signing  
- `rhtpa` — SBOM (and advisory) ingestion/analysis; RHDA consumes its APIs  
- `rhacs` — Central + pipeline / admission policy gates  
- `lightwell-repo` — Enterprise artifact manager pattern (validated / remediated / OSV proxy or seeded mirrors)  
- `spring-boot-lw-poc` — Primary sample app for Maven + LWN labs  
- `parasol-app` — Optional larger enterprise workload  

### Canonical LWN endpoints (document even when mirroring)

- Java validated: `https://packages.redhat.com/lightwell/java/validated`
- Java remediated: `https://packages.redhat.com/lightwell/java/remediated`
- Java OSV remediated: `https://packages.redhat.com/lightwell/osv/java/remediated`
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
- Do not expand scope into unrelated template cleanup, drive-by refactors, or new markdown docs unless requested or required for the task.

## Lab / Showroom content rules

- Modules must teach: (1) validated vs remediated, (2) enterprise Maven/proxy setup, (3) OSV → `.rhlw-*` pin + source diff, (4) SBOM → RHTPA, (5) pipeline/signing/policy/GitOps.
- Prefer deterministic seeded artifacts when live LWN membership is unavailable in RHDP.
- Prefer copy-pasteable `oc` / `tkn` / `mvn` / `syft` paths that match deployed chart names and namespaces.
- Update Showroom image/chart pins per [docs/SHOWROOM-UPDATE-SPEC.md](./docs/SHOWROOM-UPDATE-SPEC.md) when touching Showroom.

## Git and issue hygiene

- Align commits and PRs with a project issue when one exists; reference `Fixes #N` or `Refs #N`.
- Prefer small PRs per component chart or lab module over monolith merges.
- Do not force-push shared branches, amend published history, or skip hooks unless a human explicitly requests it.
- Do not push or open PRs to `redhat-gpe/agnosticv` or request `rhpds/` org transfer without human confirmation.

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
