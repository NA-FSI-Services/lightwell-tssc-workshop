# Module 02 — Enterprise Maven + Artifact Manager Integration

### Brief Overview

This module transitions from conceptual to hands-on, demonstrating how an enterprise Java build resolves artifacts through Lightwell Network tiers via a Nexus proxy. It covers the three consumption patterns — Direct (calling packages.redhat.com directly), Proxied (Nexus mirrors the Lightwell registry), and Seeded (artifacts pre-staged in Nexus) — and shows how Maven settings.xml profiles wire to the proxied Nexus repos. By the end, learners have proven that both the Validated and Remediated Lightwell channels resolve correctly against the Spring Boot proof-of-concept project.

### Audience and Time

- **Personas:** Java developers, DevSecOps engineers
- **Prerequisites for this module:** Module 1 complete; oc CLI available; Maven installed in Showroom terminal; Spring Boot PoC repo available at the seeded Gitea URL
- **Estimated duration:** 20 min

### Learning Objectives

- Configure Maven settings.xml profiles to proxy artifact resolution through Lightwell Validated and Remediated Nexus repositories
- Verify artifact resolution from both Lightwell tiers by running a clean Maven build against the Spring Boot PoC

### Lab Structure

| Section | Title | Duration |
|---------|-------|----------|
| 1 | Three consumption patterns overview | 3 min |
| 2 | Authentication approach and Nexus URL discovery | 2 min |
| 3 | Two Maven profile types (Validated, Remediated) | 3 min |
| 4 | Exercise 1: Resolution — mvn dependency:get | 5 min |
| 5 | Exercise 2: Consumption — mvn clean verify on Spring Boot PoC | 7 min |

### Detailed Steps

1. Read the three consumption patterns section: Direct, Proxied, Seeded — understand that the lab uses the Proxied pattern with Nexus acting as mirror.
2. Retrieve the Nexus URL and credentials from the pre-populated ConfigMap in the `lw-poc-<username>` namespace (or a shared `lightwell-repo` namespace ConfigMap).
3. Review the provided `settings.xml` which defines two profiles: `lightwell-validated` (pointing to the Validated Nexus repo) and `lightwell-remediated` with `lightwell-remediated-pins` (pointing to the Remediated Nexus repo).
4. Inspect the profile `repositories` and `pluginRepositories` entries to confirm they point to the correct Nexus proxy URLs.
5. **Exercise 1:** Run `mvn dependency:get -Dartifact=<groupId>:<artifactId>:<version> -s settings.xml -Plightwell-validated` to pull a single artifact from the Validated channel and confirm it resolves.
6. **Exercise 1 verification:** Check the Maven output for `BUILD SUCCESS` and confirm the artifact was downloaded from the Nexus URL (not Maven Central).
7. **Exercise 2:** Run `mvn clean verify -s settings.xml -Plightwell-validated` against the Spring Boot PoC to build against Validated coordinates.
8. **Exercise 2 verification:** Confirm `BUILD SUCCESS` and note that all Spring Boot dependencies resolved from the lightwell-validated Nexus repo.
9. Run `mvn clean verify -Plightwell-remediated,lightwell-remediated-pins` (using the default settings.xml or specifying `-s settings.xml`) to prove Remediated tier resolution.
10. **Verification:** Confirm `BUILD SUCCESS` and that remediated coordinate artifacts appear in the local Maven repo cache with `.rhlw-*` version suffixes.

### Key Takeaways

- The Proxied consumption pattern is the recommended enterprise approach — Nexus acts as gateway to Lightwell, allowing credential management and audit logging at the proxy layer.
- Maven settings.xml profiles are the switching mechanism between Lightwell tiers; the same `pom.xml` can build against either tier without modification.
- `mvn dependency:get` is the fastest way to test channel connectivity before running a full build.
- Artifact resolution from the correct Nexus repository (not Maven Central) is the observable proof that the proxy configuration is working.
- The seeded Spring Boot PoC used in this module will be replaced by a scaffolded repo in Module 3.

### Infrastructure Notes

- Nexus instance must be running with two proxy repositories pre-configured: one for Lightwell Validated and one for Lightwell Remediated, both backed by packages.redhat.com/lightwell/*.
- The provided `settings.xml` file must be pre-staged in the learner's Showroom home directory or the seeded Gitea repo.
- Gitea must have the spring-boot-lw-poc repo seeded for the learner's username before the module begins.
- Maven local repository cache lives in the Showroom home directory (root-owned PVC).
