# Module 04 — 2.2 Remediated pin

### Brief Overview

Broken default pin on `pom.xml`. Learner reads a Lightwell OSV / fixed event and sets the exact `.rhlw-*` version (`commons-lang3:3.14.0.rhlw-00001`). Check: dependency tree shows **that** GAV from Nexus Remediated. **Callout:** Python `+rhlw.*` on requirements.txt (text only).

### Audience and Time

- **Prerequisites:** 2.1; app repo or Module 2 Gitea tree; OSV fixture in Nexus / ConfigMap
- **Estimated duration:** TBD

### Learning Objectives

- Map an OSV `fixed` event to a Maven exact pin
- Commit the pin on the scored pom (not only a profile that is never used)
- Call out PEP 440 local version analogue

### Lab Structure

| Section | Title | Duration |
|---------|-------|----------|
| 1 | OSV / Lightwell fixed event | TBD |
| 2 | Your change: pom default pin | TBD |
| 3 | Check: tree shows `.rhlw-*` | TBD |
| 4 | Callout: Python +rhlw | TBD |

### Detailed Steps

1. Inspect seeded OSV / GAV (`LW-DEMO-0002` / commons-lang3). Worked example uses a different GAV.
2. Change **default** `<commons.lang3.version>` to `3.14.0.rhlw-00001` (dep-gate later uses the same pin).
3. `mvn dependency:tree` with Remediated settings must list that GAV from Nexus.
4. Optional source-diff of stub sources jar (v1 Module 4 material) as teaching, not the Check.
5. Python callout: `package==1.0.0+rhlw.00001` style — no FastAPI repo required.

### Key Takeaways

- Remediated is exact-version, not “latest”.
- Track 7 VEX is bound to **this** GAV.

### Infrastructure Notes

- Seed pin / broken default: V2-13 pom + V2-18 VEX beside the GAV.
