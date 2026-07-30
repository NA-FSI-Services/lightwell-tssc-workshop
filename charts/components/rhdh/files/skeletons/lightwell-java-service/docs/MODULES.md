# Modules 2–5 — using this scaffold

| Module | Focus | What to do in this repo |
|--------|--------|-------------------------|
| **2** — Enterprise Maven + artifact manager | Validated vs Remediated remotes | `settings.xml` profiles `lightwell-validated` / `lightwell-remediated`; `LW_USERNAME` / `LW_PASSWORD`; `LIGHTWELL_NEXUS_URL` |
| **3** — OSV triage + exact-version remediation | `.rhlw-0000X` pins | Enable `lightwell-remediated-pins`; pin `commons-lang3` `3.14.0.rhlw-00001`; compare with OSV `fixed` (e.g. `spring-core` `5.3.18.rhlw-00003` in lightwell-repo sample) |
| **4** — SBOM + RHTPA (RHDA) | CycloneDX ingest | `syft` / build SBOM → Trusted Profile Analyzer; IDE RHDA against RHTPA APIs |
| **5** — Pipeline signing, policy, GitOps | RHTAS + RHACS + Argo CD | Apply `.tekton/pipeline.yaml` (keyless `cosign sign`); optional `acs-image-check`; promote via GitOps |

## Env placeholders (never commit secrets)

| Variable | Purpose |
|----------|---------|
| `LW_USERNAME` | Lightwell Network / Nexus basic auth |
| `LW_PASSWORD` | Lightwell Network / Nexus token |
| `LIGHTWELL_NEXUS_URL` | Enterprise artifact manager base (workshop Nexus Route) |

## Related charts

- `charts/components/lightwell-repo` — seeded / proxy channels
- `charts/components/rhtas` — Fulcio / Rekor keyless stack
- `charts/components/rhtpa` — SBOM analysis
- `charts/components/rhacs` — `acs-image-check` Task
- `charts/components/spring-boot-lw-poc` — reference PoC matching this layout
