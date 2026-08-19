# Module 00 — Trusted supply chain (ungated intro)

### Brief Overview

Ungated orientation for the seven-track TSSC flow. Learners see the story (Hummingbird → Lightwell → source → build → sign → prod container → compliance), what this cluster is **not**, and that progress is honor-system (Validate Jobs exist; URLs still work). **No Validate Job.** First Check is 1.1 (V2-31). AsciiDoc page is V2-42 (`index.adoc`).

### Audience and Time

- **Personas:** Application developers, DevSecOps, platform engineers
- **Prerequisites:** RHDP Showroom; oc available
- **Estimated duration:** TBD (untimed until dry run)

### Learning Objectives

- Name the seven TSSC tracks in order
- State three things this claim does not pretend to be (hosted Konflux, physical air-gap, Hummingbird factory)
- Know that each later module has a Your change + Check (honor system)

### Lab Structure

| Section | Title | Duration |
|---------|-------|----------|
| 1 | Seven-track diagram | TBD |
| 2 | What this cluster is not | TBD |
| 3 | Honor system / Validate Jobs | TBD |

### Detailed Steps

1. Show the seven-track linear diagram (not FSI-branded). **Visual:** https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/48 — do not invent the PNG here.
2. Call out: Java is scored; Python and Artifactory are in-module callouts; no Modules 7–9 FastAPI path.
3. What this is not: not Konflux-on-the-claim; not a data diode; not FIPS lab evidence; VM/bootc is a Track 6 sentence.
4. Honor system: Validate Jobs grade live cluster/git state (report quiz keys are V2-59); no UI lock; no Solve. Shared rerun snippet is `partials/validate-job-rerun.adoc` (V2-55).
5. Point at `demo-userinfo-*` ConfigMaps for discovery. Do not send learners to GitHub for lab git.
6. Enablement is **after** the workshop: internal seven-track checklist (V2-46 / `appendix-enablement-checklist.adoc`). Not a live PoV. No visual on that page.

### Key Takeaways

- One linear flow; coverage-first gated modules, not v1 Java-then-Python.
- First scored Check is 1.1, not this page.

### Infrastructure Notes

- No cluster mutation required for this page.
- Diagram asset: `content/modules/ROOT/images/` once the visual issue lands.
