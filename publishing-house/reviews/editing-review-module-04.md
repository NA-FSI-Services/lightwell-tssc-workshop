# Editing Review — Module 04: OSV Triage and Exact-Version Remediation

**File:** `content/modules/ROOT/pages/module-04-osv.adoc`
**Review date:** 2026-08-12
**Reviewer:** rhdp-publishing-house:module-reviewer

---

## Summary

| Dimension | Score | Findings |
|-----------|-------|----------|
| Structure | 0.60 | 1 |
| Pedagogy | 0.60 | 1 |
| Style | 0.80 | 1 |
| Technical Accuracy | 1.00 | 0 |
| Formatting | 0.80 | 2 |
| Intro Quality | 1.00 | 0 |
| Demo Structure | 1.00 | 0 |

**Total findings:** 4 (1 High, 1 Medium, 1 Medium-formatting, 1 Warning)

This is the cleanest module so far — technical accuracy is perfect.

---

## Findings

### HIGH — Missing `=== Verify` sections in all 3 exercises (B.12)

**Line:** 66  
None of Exercises 1–3 has a dedicated `=== Verify` subsection. Classic Showroom pattern requires explicit verification headings:
- Exercise 1 (line 66): has only an Optional numbered step
- Exercise 2 (line 122): no verification at all
- Exercise 3 (line 167): verification embedded as a numbered step rather than a dedicated section

**Fix:** Add `=== Verify` subsections after each exercise's procedure steps.

---

### MEDIUM — Em dashes in prose and bullet items (C.6)

**Lines:** 8, 56, 57, 58, 59, 60, 61, 65 (8 instances)  
Em dashes appear in the intro paragraph and throughout the OSV conventions bullet list:
- Lines 56–61: OSV field definitions (`*Primary id* — Lightwell`, `*aliases* — known`, etc.)
- Lines 8, 65: intro and exercise-transition prose

**Fix for bullet items:** Replace ` — ` with a colon after each bold term:
```
* *Primary id*: Lightwell-assigned identifier
* *aliases*: known upstream CVE/GHSA IDs
```
**Fix for prose:** Replace with a comma or restructure the sentence.

---

### MEDIUM — Missing blank line before section heading (C.7)

**Line:** 66  
The section heading `== Exercise 1: Inspect sample OSV...` immediately follows the paragraph ending at line 65 with no blank line separator. AsciiDoc requires a blank line before a section title — without it, the heading may render as plain paragraph text.

**Fix:** Add a blank line before line 66.

---

### WARNING — 3 images missing `link=self,window=blank` (C.1)

**Lines:** 103, 148, 224  
- `module-04-osv-fixed-pin.png`
- `module-04-source-diff.png`
- `module-04-pom-rebuild.png`

**Fix:** Add `link=self,window=blank` to each image macro's attribute list.

---

## Spec Alignment Checks

### SA-1: Outline Coverage — PASS
All outline sections covered: OSV record structure, fixed-event identification, .rhlw-* pin scheme, pom.xml update, dependency tree verification.

### SA-2: Learning Objectives Match — PASS
5 learning objectives present matching outline-defined goals.

### SA-3: Duration Alignment — PASS
Content volume consistent with 20-minute target.

### RS-1: Product Name Accuracy — PASS
CVE, OSV, RHTPA, RHDP, RHDA all expanded on first use in this module.

### RS-2: Version Consistency — PASS
No hardcoded OCP version strings; `{java-osv-url}` used in place of hardcoded URL.

---

## Items Verified Clean

- 5 learning objectives present (≥3 required)
- 3 exercises present (≥2 required)
- All exercise steps use numbered lists; learning objectives use bullet list
- All code blocks carry `[source,<lang>]` annotations; no bare blocks
- All bash blocks carry `role=execute`; JSON and XML blocks correctly omit it
- `include::partial$student-username-form.adoc[]` resolves; all 4 `xref:` targets exist
- All images have descriptive alt text
- No hardcoded cluster URLs, usernames, or passwords; Nexus URL built dynamically via `oc get route`
- `{java-osv-url}` declared in `antora.yml`
- All headings sentence-case; no skipped heading levels
- `oc` subcommands lowercase throughout
- JSON, XML, and bash blocks all syntactically valid
- No vague marketing terms, unsupported superlatives, non-inclusive language
- All key acronyms expanded on first use; Oxford comma present; gender-neutral throughout

---

## Recommended Priority

1. **Add blank line before line 66** — potential rendering bug (heading renders as prose)
2. **Add `=== Verify` sections** to all 3 exercises — required for classic Showroom pattern
3. **Replace em dashes** in OSV bullet items and prose (8 instances) — colon pattern is cleaner for definition lists
4. **Add image link attributes** — lightbox usability (3 images)
