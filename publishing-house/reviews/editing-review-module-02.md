# Editing Review — Module 02: Enterprise Maven + Artifact Manager Integration

**File:** `content/modules/ROOT/pages/module-02-maven.adoc`
**Review date:** 2026-08-12
**Reviewer:** rhdp-publishing-house:module-reviewer

---

## Summary

| Dimension | Score | Findings |
|-----------|-------|----------|
| Structure | 0.60 | 3 |
| Pedagogy | 0.60 | 3 |
| Style | 0.80 | 2 |
| Technical Accuracy | 0.60 | 1 |
| Formatting | 0.90 | 1 |
| Intro Quality | 1.00 | 0 |
| Demo Structure | 1.00 | 0 |

**Total findings:** 7 (4 High, 2 Medium, 1 Warning)

---

## Findings

### HIGH — Missing `=== Verify` section in Exercise 1 (B.12)

**Line:** 152  
Exercise 1 ("Browse Nexus repositories") has no `=== Verify` subsection. The optional "confirm the seed Job finished" step does not satisfy the requirement. Classic Showroom pattern requires a dedicated verification heading with explicit success criteria.

**Fix:** Add `=== Verify` after the exercise steps.

---

### HIGH — Missing `=== Verify` section in Exercise 2 (B.12)

**Line:** 202  
Exercise 2 ("Validated stream") has no `=== Verify` subsection. Inline "Expected:" prose under each Experiment does not satisfy the requirement.

**Fix:** Add `=== Verify` after the exercise steps.

---

### HIGH — Missing `=== Verify` section in Exercise 3 (B.12)

**Line:** 297  
Exercise 3 ("Remediated stream") has no `=== Verify` subsection.

**Fix:** Add `=== Verify` after the exercise steps.

---

### HIGH — `[source,bash]` block missing `role=execute` (E.3a)

**Line:** 69  
The `oc create secret` command block is missing `role=execute`. All other bash blocks in this module correctly include it. Without `role=execute`, the Showroom terminal-targeting button will not appear.

**Fix:** Add `role=execute` to the code block at line 69.

---

### MEDIUM — Em dashes throughout prose and headings (D.8 / C.6)

**Lines:** 42, 44, 58, 77, 196, 214, 221, 263, 280, 303, 318, 335, 368, 393+ (17 instances)  
Em dashes (—) appear pervasively in narrative prose and headings.

**Fix:** Replace with comma, colon, or rephrase. In exercise-title headings, use ` - ` (hyphen-minus with spaces).

---

### MEDIUM — Numbers written as words instead of numerals (D.6)

**Lines:** 17, 177, 179  
- "two Maven experiments" → "2 Maven experiments"
- Heading "two experiments" → "2 experiments"
- "two kinds of Maven content" → "2 kinds of Maven content"

---

### WARNING — 4 images missing `link=self,window=blank` (C.1)

**Lines:** 54, 119, 173, 200  
All four `image::` macros lack the lightbox attributes:
- `module-02-direct-vs-proxy.png`
- `module-02-maven-profiles.png`
- `module-02-nexus-repos.png`
- `module-02-seed-experiments.png`

**Fix:** Add `link=self,window=blank` inside the brackets of each image macro.

---

## Spec Alignment Checks

### SA-1: Outline Coverage — PASS
All outline sections covered: Nexus proxy architecture, Maven settings.xml configuration, validated stream, remediated stream, GAV coordinate explained.

### SA-2: Learning Objectives Match — PASS
6 learning objectives present; all map to outline-defined goals.

### SA-3: Duration Alignment — PASS
Content volume consistent with 20-minute target.

### RS-1: Product Name Accuracy — PASS
RHDP, LWN, RHDH, Maven all use correct full names with expansions on first use.

### RS-2: Version Consistency — PASS
No hardcoded OCP version strings; URL attributes used in place of hardcoded URLs.

---

## Items Verified Clean

- 6 learning objectives present (≥3 required)
- 3 exercises present (≥2 required)
- Exercise steps use numbered lists, not bullets
- All code blocks carry `[source,<lang>]` annotations
- Both `include::partial$` references resolve to existing files
- All `{attribute}` references (`{java-validated-url}`, `{java-remediated-url}`, `{java-osv-url}`) defined in `antora.yml`
- All images have descriptive alt text
- All `xref:` links correctly omit `^`; no bare external links without `^`
- All headings sentence-case; no skipped heading levels
- `oc` subcommands lowercase throughout
- All other `bash` blocks carry `role=execute` (except line 69)
- No vague marketing terms, unsupported superlatives, non-inclusive language
- Acronyms expanded on first use: RHDP, LWN, RHDH, POM, PoC, GAV, ASL
- Oxford comma present in all 3+ item lists; gender-neutral language throughout

---

## Recommended Priority

1. **Add `role=execute` to line 69** — functional issue affecting terminal integration
2. **Add `=== Verify` sections** to all 3 exercises — required for classic Showroom pattern
3. **Replace em dashes** — style conformance (17 instances)
4. **Change "two" → "2"** at lines 17, 177, 179
5. **Add image link attributes** — lightbox usability (4 images)
