# Module 05 — SBOM Generation and Analysis with RHTPA

### Brief Overview

This module covers supply-chain metadata as a system of record, focusing on Software Bill of Materials (SBOM) generation and ingestion. It distinguishes Red Hat Trusted Profile Analyzer (RHTPA) — a cluster-hosted SBOM ingestion and analysis service — from RHDA (Red Hat Dependency Analytics, an IDE shift-left tool), so learners understand where each fits. Learners authenticate to the TPA UI via the workshop Keycloak SSO realm, generate a CycloneDX SBOM from the Spring Boot PoC build output using syft, and ingest it into RHTPA via the v3 REST API using an OIDC bearer token obtained by password grant.

### Audience and Time

- **Personas:** Java developers, DevSecOps engineers, platform engineers, application security engineers
- **Prerequisites for this module:** Module 4 complete; Spring Boot PoC built (`target/` directory present); syft binary available in Showroom home; oc CLI available; RHTPA running in the cluster; Keycloak SSO realm configured with demo user
- **Estimated duration:** 20 min

### Learning Objectives

- Generate a CycloneDX SBOM from Java build output using syft
- Ingest the SBOM into Red Hat Trusted Profile Analyzer via the v3 API using an OIDC bearer token

### Lab Structure

| Section | Title | Duration |
|---------|-------|----------|
| 1 | Tool overview: RHTPA vs. syft vs. RHDA — role of each | 3 min |
| 2 | Exercise 0: SSO confirmation — log into TPA UI via Keycloak | 4 min |
| 3 | Exercise 2: SBOM generation with syft (CycloneDX) | 6 min |
| 4 | Exercise 3: SBOM ingestion via RHTPA v3 API | 7 min |

### Detailed Steps

1. Read the tool overview: RHTPA ingests and analyzes SBOMs at cluster scale; syft generates SBOMs from local build artifacts; RHDA provides IDE-level shift-left analysis. They are complementary, not alternatives.
2. **Exercise 0 — SSO:** Run `oc -n sso get configmap demo-userinfo-keycloak -o yaml` to extract the Keycloak base URL, realm name, client ID, username, and password for the demo user.
3. Open the RHTPA UI URL (retrieve from cluster routes: `oc get routes -A | grep tpa`) in the browser. Click **Login** — the browser redirects to Keycloak. Log in with the demo credentials from the ConfigMap.
4. Confirm the RHTPA UI loads with the demo user's session visible. This confirms SSO wiring between RHTPA and Keycloak is working.
5. **Exercise 2 — SBOM generation:** Confirm the Spring Boot PoC has been built and the `target/` directory contains compiled classes and the JAR. If not, run `mvn clean verify -Plightwell-remediated,lightwell-remediated-pins` first.
6. Run `syft packages "dir:target" -o cyclonedx-json > sbom.cyclonedx.json` to generate a CycloneDX JSON SBOM from the build output.
7. Inspect `sbom.cyclonedx.json` briefly — note the `metadata.component` entry (the Spring Boot PoC) and the `components` array listing all resolved dependencies including the `commons-lang3:3.14.0.rhlw-00001` coordinate from Module 4.
8. **Exercise 3 — RHTPA ingestion:** Obtain an OIDC bearer token using a password grant:
   ```
   curl -s -X POST https://<keycloak-url>/realms/<realm>/protocol/openid-connect/token \
     -d "grant_type=password&client_id=<client>&username=<user>&password=<pass>" \
     | jq -r '.access_token'
   ```
9. Store the token in a shell variable: `TOKEN=$(...)`.
10. Retrieve the RHTPA base URL: `RHTPA_BASE=$(oc get route -n rhtpa -o jsonpath='{.items[0].spec.host}')` (adjust namespace as needed).
11. Ingest the SBOM: `curl -X POST https://${RHTPA_BASE}/api/v3/sbom -H "Authorization: Bearer ${TOKEN}" -H "Content-Type: application/json" -d @sbom.cyclonedx.json`.
12. **Verification:** Confirm the curl response returns HTTP 201 and a JSON body containing an SBOM ID.
13. Navigate to the RHTPA UI and confirm the ingested SBOM appears in the list with the Spring Boot PoC component name.

### Key Takeaways

- RHTPA is the enterprise SBOM system of record — once ingested, SBOMs can be queried for vulnerability correlation, license analysis, and policy enforcement.
- syft is a standalone SBOM generator that works against any directory or container image; it does not require network access to RHTPA to generate output.
- The CycloneDX JSON format is RHTPA's preferred ingest format; the v3 API accepts it via a simple POST with a bearer token.
- OIDC password grant is used here for workshop simplicity — in production, the Tekton pipeline (Module 6) obtains the token via a service account client credentials flow.
- The SBOM generated in this module will include the `.rhlw-00001` coordinate from Module 4, demonstrating that remediation activity is reflected in the supply-chain metadata.

### Infrastructure Notes

- Keycloak realm with demo user must be pre-configured; credentials accessible from `demo-userinfo-keycloak` ConfigMap.
- RHTPA v3 API endpoint must be accessible from the Showroom terminal (network policy permitting curl from Showroom pod to RHTPA route).
- syft binary must be pre-staged in the Showroom home directory (or installed in the base Showroom image).
- jq must be available in the Showroom terminal for token extraction from the OIDC response.
- RHTPA namespace and route name: confirm exact values during infrastructure provisioning — they appear in exercises as `<rhtpa-namespace>` placeholders.
