# Module 08 — Remediated PyPI + SPDX/SBOM to RHTPA

### Brief Overview

This module parallels Modules 4 and 5 for the Python ecosystem. It confirms that the Lightwell Remediated PyPI channel is enabled (a configuration toggle that the workshop environment controls), pins the workshop marker package using the PEP 440 local version label (`+rhlw.00001`) syntax in `requirements.txt`, and demonstrates both SPDX and CycloneDX SBOM generation using syft — illustrating the difference between the Python-native SPDX format and the RHTPA-preferred CycloneDX format. The CycloneDX SBOM is ingested into RHTPA via the v3 API, mirroring Module 5 exactly for the Python track.

### Audience and Time

- **Personas:** Python developers, DevSecOps engineers, application security engineers
- **Prerequisites for this module:** Module 7 complete; FastAPI app repo cloned and pip-installed once; syft binary available; RHTPA running; Keycloak SSO available (bearer token workflow from Module 5 is reused)
- **Estimated duration:** 25 min

### Learning Objectives

- Apply a PEP 440 local version pin using the +rhlw.00001 syntax to requirements.txt for a Remediated PyPI package
- Generate both SPDX and CycloneDX SBOMs from Python build output using syft and contrast their structure
- Ingest a CycloneDX SBOM for a Python application into Red Hat Trusted Profile Analyzer via the v3 API

### Lab Structure

| Section | Title | Duration |
|---------|-------|----------|
| 1 | Java vs. Python format comparison: CycloneDX vs. SPDX | 3 min |
| 2 | Exercise 1: Verify Remediated PyPI is enabled via ConfigMap | 3 min |
| 3 | Exercise 2: Pin lw-workshop-pypi in requirements.txt | 5 min |
| 4 | Exercise 3: Inspect wheel dist-info and contrast SPDX vs. CycloneDX | 5 min |
| 5 | Exercise 4: Generate SPDX and CycloneDX inventories with syft | 5 min |
| 6 | Exercise 5: Ingest CycloneDX SBOM into RHTPA | 4 min |

### Detailed Steps

1. Read the Java vs. Python format comparison: Java projects commonly use CycloneDX via Maven plugins; Python projects may use SPDX natively (pip, pip-licenses). RHTPA accepts CycloneDX for both — making it the common denominator for enterprise ingestion.
2. **Exercise 1 — Verify Remediated PyPI enabled:** Run `oc get configmap -n lightwell-repo -o yaml | grep pypi_remediated_enabled` (or inspect the specific ConfigMap key). Confirm the value is `true`.
3. Note that enabling Remediated PyPI means the Nexus proxy now exposes the Lightwell Remediated PyPI index in addition to the Validated index.
4. **Exercise 2 — Pin requirements.txt:** Open `requirements.txt` in the scaffolded `lw-fastapi` repo.
5. Locate (or add) the `lw-workshop-pypi` dependency line. Update it to: `lw-workshop-pypi==1.0.0+rhlw.00001`.
6. Note: PEP 440 local version labels (`+<local>`) are the Python equivalent of Maven's `.rhlw-*` suffix. They are not published to pypi.org — they only resolve from the Lightwell Remediated Nexus index.
7. Install the pinned dependency: `PIP_CONFIG_FILE=<remediated-pip-conf> python3 -m pip install lw-workshop-pypi==1.0.0+rhlw.00001`.
8. **Verification:** Confirm install succeeds and the package version shown by `pip show lw-workshop-pypi` is `1.0.0+rhlw.00001`.
9. **Exercise 3 — Inspect wheel dist-info:** Navigate to the site-packages directory and find `lw_workshop_pypi-1.0.0+rhlw.00001.dist-info/METADATA`. Inspect the `Version` field confirming the local label is preserved in the installed package metadata.
10. Compare this to a standard CycloneDX component entry (show example) vs. an SPDX `PackageVersion` field — note that PEP 440 local labels may be represented differently across formats.
11. **Exercise 4 — Generate SBOMs:** Run `syft packages "dir:." -o spdx-json > sbom.spdx.json` from the `lw-fastapi` project root.
12. Run `syft packages "dir:." -o cyclonedx-json > sbom.cyclonedx.json` to generate the CycloneDX variant.
13. Open both files briefly. Note differences: SPDX uses `SPDXID` and `packages` array with `versionInfo`; CycloneDX uses `components` with `version`. Both should show `lw-workshop-pypi` at version `1.0.0+rhlw.00001`.
14. **Exercise 5 — RHTPA ingestion:** Reuse the OIDC token retrieval pattern from Module 5 to obtain a fresh bearer token (token TTL may have expired).
15. Ingest the CycloneDX SBOM: `curl -X POST https://${RHTPA_BASE}/api/v3/sbom -H "Authorization: Bearer ${TOKEN}" -H "Content-Type: application/json" -d @sbom.cyclonedx.json`.
16. **Verification:** HTTP 201 response with SBOM ID. Navigate to RHTPA UI and confirm the `lw-fastapi` component appears in the SBOM list with the `lw-workshop-pypi:1.0.0+rhlw.00001` entry visible.
17. Commit the `requirements.txt` change: `git add requirements.txt && git commit -m "fix: pin lw-workshop-pypi to 1.0.0+rhlw.00001" && git push`.

### Key Takeaways

- PEP 440 local version labels (`+rhlw.00001`) are the Python-ecosystem equivalent of Maven `.rhlw-*` suffixes — both are opaque to the upstream registry and only resolvable from the Lightwell Remediated channel.
- SPDX is the Python-native SBOM format (supported by pip and pip-licenses), while CycloneDX is the RHTPA-preferred ingest format — syft bridges both ecosystems by generating either output.
- The RHTPA v3 API ingestion workflow is identical for Java and Python SBOMs — only the content of the SBOM changes.
- Inspecting wheel dist-info metadata confirms that the `+rhlw.00001` local label survives the install process and appears in the package's declared version.
- The `lw-workshop-pypi` marker package is the Python analogue of `commons-lang3:3.14.0.rhlw-00001` — a workshop-controlled artifact that proves the Remediated channel resolves correctly.

### Infrastructure Notes

- Nexus must have a separate Remediated PyPI simple index proxy configured, toggled by the `pypi_remediated_enabled` ConfigMap key. When enabled, the Nexus repo is active; when disabled, requests return 404 for `.rhlw.*` coordinates.
- `lw-workshop-pypi==1.0.0+rhlw.00001` wheel must be pre-published to the Remediated PyPI channel in Nexus.
- syft binary must be pre-staged in the Showroom home directory (same binary used in Module 5).
- RHTPA v3 API must be accessible from the Showroom terminal (same network path as Module 5).
- jq must be available for OIDC token extraction (same as Module 5).
