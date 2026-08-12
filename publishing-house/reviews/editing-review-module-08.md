# Editing Review — Module 08: Remediated PyPI + SPDX/SBOM to RHTPA

**File:** `content/modules/ROOT/pages/module-08-python-sbom.adoc`
**Review date:** 2026-08-12
**Reviewer:** rhdp-publishing-house:module-reviewer

---

## Summary

| Dimension | Score | Findings |
|-----------|-------|----------|
| Structure | 0.60 | 1 |
| Pedagogy | 0.60 | 1 |
| Style | 0.80 | 2 |
| Technical Accuracy | 0.60 | 1 |
| Formatting | 0.90 | 1 |
| Intro Quality | 1.00 | 0 |
| Demo Structure | 1.00 | 0 |

**Total findings:** 5 (2 High, 2 Medium, 1 Warning)

---

## Findings

### HIGH — Missing `=== Verify` sections in all 5 exercises (B.12)

**Lines:** 39+  
None of Exercises 1–5 has a dedicated `=== Verify` subsection. Classic Showroom pattern requires explicit verification headings with success criteria. Currently uses inline "Expect…" prose and TIP blocks instead.

**Fix:** Add `=== Verify` subsections to each exercise with clear pass/fail criteria the student can observe.

---

### HIGH — Non-standard placeholder `@@LW_USER@@` in code block (E.4)

**Line:** 68  
Inside the Exercise 2-A code block:
```
export STUDENT_USER='@@LW_USER@@'
```
This is not an AsciiDoc attribute substitution — it renders literally on the page.

**Fix:** Replace with `{student_username}` (already defined in `antora.yml`).

---

### MEDIUM — Em dashes throughout prose and headings (C.6 / D.8)

**Lines:** 22, 25, 39, 61, 99, 142, 188, 191, 242, 249, 251, 264, 303+  
Em dashes (—) appear in 7 headings and multiple prose lines.

**Fix:** In prose, replace with comma/semicolon. In exercise-title headings, replace with a colon or ` - ` (hyphen-minus with spaces).

---

### WARNING — Images missing `link=self,window=blank` (C.1)

**Lines:** 163, 340  
Both `image::` macros lack the lightbox/new-tab attributes:
- `image::module-08-spdx-vs-cyclonedx.png[...]`
- `image::module-08-rhtpa-python-sbom.png[...]`

**Fix:** Add `link=self,window=blank` to both image macros.

---

## Spec Alignment Checks

### SA-1: Outline Coverage — PASS
All 5 outline sections covered (Remediated tier concepts, pip.conf update, syft SPDX/CycloneDX generation, RHTPA API ingestion, diff from Java track).

### SA-2: Learning Objectives Match — PASS
5 learning objectives present matching outline requirements.

### SA-3: Duration Alignment — PASS
Content volume consistent with 25-minute target.

### RS-1: Product Name Accuracy — PASS
RHTPA, RHTAS, OpenShift Pipelines all use correct full names with expansions on first use.

### RS-2: Version Consistency — PASS
No hardcoded OCP version strings; no mismatch with spec `ocp_version: 4.20`.

---

## Items Verified Clean

- 5 learning objectives present (≥3 required)
- 5 exercises present (≥2 required)
- No bullet-based procedure steps; prose + code block pattern used correctly
- All code blocks carry `[source,<lang>]` annotations
- `include::partial$student-username-form.adoc[]` resolves correctly
- All `{attribute}` references (`{python-remediated-url}`, `{python-remediated-simple-url}`) defined in `antora.yml`
- Images have descriptive alt text
- No bare external links without `^`; all xrefs correctly omit `^`
- All headings sentence-case; no skipped heading levels
- `oc` subcommands use lowercase throughout
- All `bash` code blocks carry `role=execute`
- No vague marketing terms, unsupported superlatives, or non-inclusive language
- SPDX, RHTPA, PVC expanded on first use
- Oxford comma present in all 3+ item lists

---

## Recommended Priority

1. **Fix `@@LW_USER@@` placeholder** — will render broken in all deployments
2. **Add `=== Verify` sections** — required for classic Showroom pattern
3. **Replace em dashes** — style conformance
4. **Add image link attributes** — lightbox usability
