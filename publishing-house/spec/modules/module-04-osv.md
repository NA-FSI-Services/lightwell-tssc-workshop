# Module 04 — OSV Triage and Exact-Version Remediation

### Brief Overview

This module teaches the complete OSV-driven remediation evaluation loop for a Java dependency. Learners read an OSV fixed event in the RHLW ID scheme to identify the exact `.rhlw-*` version coordinate, diff the upstream source jar against the remediated `-sources.jar` to confirm the change is a scoped security backport (not a broader upstream update), pin the remediated coordinate in `pom.xml`, and rebuild to verify the dependency tree contains the exact fixed version. This process directly mirrors what Lightwell Network customers do when acting on an OSV alert.

### Audience and Time

- **Personas:** Java developers, DevSecOps engineers, application security engineers
- **Prerequisites for this module:** Module 3 complete; scaffolded `spring-boot-lw-poc` repo cloned locally; Maven with Remediated profile configured; workshop OSV evaluation scripts pre-staged (`tools/osv-eval/scripts/`)
- **Estimated duration:** 20 min

### Learning Objectives

- Analyze an OSV fixed event to identify the exact-version .rhlw-* remediated coordinate for a Java dependency
- Verify a remediated source jar contains only a scoped security backport relative to the upstream version
- Apply the exact-version pin to pom.xml and rebuild to confirm the remediated coordinate resolves

### Lab Structure

| Section | Title | Duration |
|---------|-------|----------|
| 1 | OSV record format and RHLW ID scheme | 3 min |
| 2 | Evaluation loop overview | 2 min |
| 3 | Exercise 1: Identify the fixed version from the OSV record | 4 min |
| 4 | Exercise 2: Source diff — upstream vs. remediated | 6 min |
| 5 | Exercise 3: Pin commons-lang3 and rebuild | 5 min |

### Detailed Steps

1. Read the OSV record format section. Note the `id` field uses the RHLW scheme (`RHLW-XXXX`), and the `affected[].ranges[].events` array contains `introduced` and `fixed` values.
2. Review the evaluation loop diagram: read OSV → identify `.rhlw-*` pin → diff sources → update `pom.xml` → rebuild → verify.
3. **Exercise 1:** Open the provided OSV fixture file (or run `./tools/osv-eval/scripts/osv-pin.sh` to print the pin). Locate the `fixed` value in the `ranges.events` array — it should read `3.14.0.rhlw-00001`.
4. Record the full Maven coordinate: `org.apache.commons:commons-lang3:3.14.0.rhlw-00001`.
5. **Exercise 2:** Run `./tools/osv-eval/scripts/diff-sources.sh --fixture` to download and diff the upstream `commons-lang3-3.14.0-sources.jar` against the `commons-lang3-3.14.0.rhlw-00001-sources.jar` from the Remediated Nexus repo.
6. Review the diff output. Confirm the diff is limited to security-relevant changes (the backported CVE fix) and does not include broad upstream version changes that would indicate a full upgrade rather than a backport.
7. Optionally run `git diff --no-index upstream-sources/ remediated-sources/` on the extracted source trees to view individual file diffs.
8. **Exercise 3:** Open `pom.xml` in the scaffolded `spring-boot-lw-poc` repo and locate the `commons-lang3` dependency entry.
9. Update the `<version>` element from `3.14.0` to `3.14.0.rhlw-00001`.
10. Run `mvn clean verify -Plightwell-remediated,lightwell-remediated-pins` to rebuild with the pinned coordinate.
11. **Verification:** In the build output or by running `mvn dependency:tree`, confirm that `commons-lang3:3.14.0.rhlw-00001` appears as the resolved version (not `3.14.0`).
12. Commit the `pom.xml` change: `git add pom.xml && git commit -m "fix: pin commons-lang3 to remediated coordinate 3.14.0.rhlw-00001"`.

### Key Takeaways

- The `.rhlw-*` version suffix is the machine-readable signal that a coordinate is a Lightwell remediated backport, not an upstream release.
- Source diffing is the verification step that confirms the remediation is scoped — a broad diff would indicate an unexpected upgrade rather than a targeted security backport.
- The OSV `fixed` field directly gives the exact coordinate to pin; there is no guessing or approximation required.
- Updating `pom.xml` with the exact `.rhlw-*` pin and rebuilding is the complete remediation action — no other changes to the project are needed.
- This exact-version pin approach is what the Tekton dep-gate pipeline in Module 6 will enforce — it checks that `.rhlw-*` pins are present before allowing a build to proceed.

### Infrastructure Notes

- Workshop OSV fixture file pre-staged in `tools/osv-eval/scripts/` or the Showroom home directory.
- Scripts `osv-pin.sh` and `diff-sources.sh` must be executable and have access to the Remediated Nexus repo URL (read from environment or ConfigMap).
- The `commons-lang3:3.14.0.rhlw-00001` coordinate must be available in the Remediated Nexus proxy before the module starts.
- Learner must have the scaffolded `spring-boot-lw-poc` repo checked out from Module 3.
