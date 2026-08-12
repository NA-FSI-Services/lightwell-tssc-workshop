# Module 01 — AI Vulnerability Storm and Lightwell Network Overview

### Brief Overview

This module establishes the conceptual foundation for the entire workshop. It covers the "remediation gap" — the window between a CVE being fixed upstream and that fix reaching production artifacts — and explains how the Red Hat Lightwell Network addresses it through its three-tier model: Validated, Remediated, and OSV. Learners map the supply-chain metadata types (SBOM, VEX, SLSA L3, OSV) to the tools they will use in subsequent modules. The module closes with a crosswalk table aligning every later module to its corresponding TSSC capability.

### Audience and Time

- **Personas:** Application developers, DevSecOps engineers, platform engineers
- **Prerequisites for this module:** RHDP Showroom access provisioned; oc CLI accessible from Showroom terminal
- **Estimated duration:** 20 min (split: ~10 min conceptual, ~10 min exercises)

### Learning Objectives

- Verify Lightwell Network channel names and tier configuration using in-cluster ConfigMaps
- Analyze a sample OSV fixed event to identify the remediated version coordinate
- Map each subsequent workshop module to the TSSC capability it exercises

### Lab Structure

| Section | Title | Duration |
|---------|-------|----------|
| 1 | Background: the AI vulnerability storm and remediation gap | 5 min |
| 2 | Lightwell Network tier model (Validated, Remediated, OSV) | 3 min |
| 3 | Supply-chain metadata types and tool crosswalk | 2 min |
| 4 | Exercise 1: Confirm the channel map in the cluster | 4 min |
| 5 | Exercise 2: Inspect a sample OSV fixed event | 4 min |
| 6 | Exercise 3: Map the workshop story to TSSC tools | 2 min |

### Detailed Steps

1. Read the Background section introducing the vulnerability storm concept and the gap between upstream CVE fix and production artifact delivery.
2. Review the Lightwell Network tier diagram: Validated (curated, signed), Remediated (security-backported, exact-version), OSV (event-driven fixed records).
3. Review the supply-chain metadata table: SBOM → RHTPA, VEX → TPA, SLSA L3 → RHTAS, OSV → Lightwell remediation.
4. **Exercise 1:** Run `oc -n lightwell-repo get configmap lightwell-channels -o yaml` to view channel names and verify the cluster has the expected Validated, Remediated, and OSV entries.
5. **Exercise 1 verification:** Confirm output includes channel keys matching the expected tier names.
6. **Exercise 2:** Open the provided OSV fixed event fixture (or run `oc get routes -A` to find the workshop tool URL). Inspect the `affected[].ranges[].events` array to identify the `fixed` version value.
7. **Exercise 2 verification:** Note the `RHLW-XXXX` ID scheme and the exact `.rhlw-*` pin value in the `fixed` field.
8. **Exercise 3:** Review the crosswalk table in the module that maps Modules 2–9 to their TSSC capability (Maven proxy, RHDH golden path, OSV triage, SBOM, pipeline gates, signing, GitOps).
9. Read the Module Summary confirming the conceptual foundation is in place before proceeding to Module 2.

### Key Takeaways

- The remediation gap exists between a CVE fix merging upstream and that fix reaching a production-deployed artifact; Lightwell Network closes this gap.
- The three tiers serve different enterprise needs: Validated for curated packages, Remediated for exact-version security backports, OSV for event-driven triage.
- Supply-chain metadata (SBOM, VEX, SLSA, OSV) is not a single artifact type — each maps to a different tool in the TSSC stack.
- The in-cluster ConfigMap `lightwell-channels` is the source of truth for which Nexus proxy repos are active; later modules reference it.
- Every subsequent module builds on this mental model — the crosswalk table is the workshop's navigation aid.

### Infrastructure Notes

- Namespace: `lightwell-repo` — must be pre-created with the `lightwell-channels` ConfigMap populated before learners start.
- OSV fixture file: pre-staged in the Showroom home directory or accessible via a workshop tool route.
- No persistent storage required for this module.
