# RHDA shift-left against RHTPA (Module 4)

Red Hat **Dependency Analytics (RHDA)** is the IDE front-end for software composition analysis. In this workshop, **Trusted Profile Analyzer (RHTPA)** remains the SBOM / advisory system of record; RHDA consumes TPA intelligence so developers see risks on manifests (for Java, `pom.xml`) before pipeline gates fire.

This workshop does **not** deploy VS Code, JetBrains IDEs, or a full IDE stack into the RHDP cluster.

## Narrative (what to teach)

1. Generate or upload a CycloneDX SBOM (`syft` → RHTPA UI/API) — in-cluster / Showroom path.
2. Optionally, on an instructor or demo laptop, open the same Maven project in an IDE with RHDA pointed at the workshop TPA (or the public RHDA backend) so inline analysis mirrors TPA data.
3. Tie findings back to Lightwell remediated pins (`.rhlw-*`) and Module 3 / 5 gates.

Official product guide: [Configuring VS Code for Dependency Analytics (RHTPA Quick Start)](https://docs.redhat.com/en/documentation/red_hat_trusted_profile_analyzer/2/html/quick_start_guide/configuring-visual-studio-code-to-use-dependency-analytics_qsg).

## Showroom vs laptop

| Capability | Inside Showroom / cluster | Instructor or demo laptop |
|------------|---------------------------|---------------------------|
| RHTPA UI — browse SBOMs, advisories | Yes (Route from `charts/components/rhtpa`) | Yes (same Route URL) |
| `syft` CycloneDX generate + upload | Yes (terminal / pipeline Task `syft-sbom-rhtpa`) | Yes |
| RHDA IDE extension (VS Code / JetBrains) | **No** — not installed in Showroom | **Yes** — install from marketplace |
| Analyze `pom.xml` with RHDA | Not in Showroom browser | Open `pom.xml` after Backend URL is set |
| Full IDE / LSP stack in OpenShift | **Out of scope** (not planned) | N/A |

**Showroom learners** complete Module 4 with TPA UI + CLI/`syft` and treat RHDA as a “shift-left on your workstation” callout.  
**Instructors** may live-demo RHDA on a laptop against the catalog item’s TPA Route when SSO and network allow.

## Laptop setup (instructor / demo only)

Prerequisites on the workstation: IDE + RHDA extension, `mvn` on `PATH` for Maven manifests ([product prerequisites](https://docs.redhat.com/en/documentation/red_hat_trusted_profile_analyzer/2/html/quick_start_guide/configuring-visual-studio-code-to-use-dependency-analytics_qsg)).

1. Install **Red Hat Dependency Analytics** from the VS Code (or JetBrains) marketplace.
2. Point the extension at a backend:
   - **Default public backend:** `https://rhda.rhcloud.com` (works without workshop TPA; good for “what RHDA looks like”).
   - **Private / workshop TPA:** when your RHTPA deployment exposes an RHDA/Exhort-compatible backend URL, set:

```json
{
  "redhat.dependency.analytics.exhort.backendUrl": "https://<rhda-or-exhort-route>.apps.<domain>"
}
```

   Setting name may appear in the UI as **Red Hat Dependency Analytics: Backend URL**. See also [RHDA with a private TPA instance](https://developers.redhat.com/blog/2026/07/18/red-hat-dependency-analytics-works-your-private-trusted-profile-analyzer-instance).

3. Open the Spring Boot PoC or a `lightwell-java-service` scaffold → open `pom.xml` → run Dependency Analytics / hover wavy underlines for component analysis.
4. Compare IDE findings with the same SBOM/advisory view in the RHTPA UI for the workshop cluster.

If the workshop TPA build does not yet publish a dedicated Exhort/RHDA route, demo RHDA against the **public** backend and still upload workshop SBOMs into **cluster RHTPA** — make that split explicit to the audience.

## What stays in GitOps

| In cluster (this repo) | Not in cluster |
|------------------------|----------------|
| `charts/components/rhtpa` | VS Code / IntelliJ |
| ConfigMap `rhtpa-ingestion-info` (upload + RHDA note) | RHDA marketplace extension |
| Pipeline SBOM Task (`syft-sbom-rhtpa`) | Committed IDE settings with real customer URLs |

Optional: a scaffold may later ship `.vscode/extensions.json` *recommending* RHDA (no backend URL with secrets). Do not commit environment-specific Backend URLs with credentials.

## Related

- Chart: [`charts/components/rhtpa`](../charts/components/rhtpa/)
- Showroom page (AsciiDoc): [`docs/modules/ROOT/pages/rhda-shift-left.adoc`](./modules/ROOT/pages/rhda-shift-left.adoc) — linked from Module 4 when authored ([#17](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/17))
- Pipeline SBOM gate: [#13](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/13)
- [DEVELOPMENT-PLAN.md](../DEVELOPMENT-PLAN.md) — Module 4
