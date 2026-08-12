# Editing Review — Module 01: AI Vulnerability Storm and Lightwell Network Overview

**File:** `content/modules/ROOT/pages/module-01-overview.adoc`
**Review date:** 2026-08-12
**Reviewer:** rhdp-publishing-house:module-reviewer

---

## Summary

| Dimension | Score | Findings |
|-----------|-------|----------|
| Structure | 0.60 | 1 |
| Pedagogy | 0.60 | 1 |
| Style | 0.80 | 4 |
| Technical Accuracy | 1.00 | 0 |
| Formatting | 0.90 | 1 |
| Intro Quality | 0.60 | 3 |
| Demo Structure | 1.00 | 0 |

**Total findings:** 7 (1 High, 3 Medium, 2 Warning, 1 Warning-intro)

---

## Findings

### HIGH — Missing `=== Verify` sections in all 3 exercises (B.12)

**Line:** 127  
All 3 exercises (Exercise 1 at line 127, Exercise 2 at line 154, Exercise 3 at line 175) are missing a dedicated `=== Verify` subsection. SHOWROOM_TYPE is `classic` — verification must be authored in-content. The "Expected outcomes" text in Exercise 1 step 3 is an ordered-list item, not a verification heading.

**Fix:** Add `=== Verify` subsections after each exercise's procedure steps.

---

### MEDIUM — Em dashes in prose (C.6 / D.8)

**Lines:** 8, 10, 81, 82  
Em dashes (—) appear at:
- Line 8: `deps)—without`
- Line 10: `fits—before` and `7–9 — PyPI`
- Line 81: `browse — Lightwell`
- Line 82: `mapping — published`

**Fix:** Replace with commas, colons, or sentence restructure.

---

### MEDIUM — Broken list nesting in Exercise 1 (C.7)

**Line:** 147  
`Expected outcomes:` is an ordered-list item at line 147, immediately followed by bullet items at line 148 with no `+` list continuation. Asciidoctor will open a new unordered list outside the ordered list, breaking the intended nesting.

**Fix:** Insert a `+` line between line 147 and the first bullet.

---

### MEDIUM — Number word instead of numeral (D.6)

**Line:** 8  
`This workshop uses two complementary streams` → should be `2 complementary streams`.

---

### WARNING — RHDH acronym not expanded on first use (D.2)

**Line:** 193  
`RHDH` first appears in the capability table without being expanded to "Red Hat Developer Hub (RHDH)". This is Module 01 — no prior expansion exists.

**Fix:** Add the expansion inline in the table cell: `Red Hat Developer Hub (RHDH)`.

---

### WARNING — 4 images missing `link=self,window=blank` (C.1)

**Lines:** 32, 66, 105, 123  
- `module-01-osv-pin-rebuild-loop.png`
- `module-01-validated-vs-remediated.png`
- `module-01-control-decision.png`
- `module-01-artifact-metadata.png`

**Fix:** Add `link=self,window=blank` to each image macro's attribute list.

---

## Spec Alignment Checks

### SA-1: Outline Coverage — PASS
All outline sections covered: AI vulnerability landscape, Lightwell Network tiers, OSV schema, cluster ConfigMap discovery, capability overview table.

### SA-2: Learning Objectives Match — PASS
5 learning objectives present matching outline-defined goals.

### SA-3: Duration Alignment — PASS
Content volume consistent with 20-minute target.

### RS-1: Product Name Accuracy — PASS
All product names use correct full names; attributes used for URLs.

### RS-2: Version Consistency — PASS
No hardcoded OCP version strings; all URL values use defined attributes from `antora.yml`.

---

## Items Verified Clean

- 5 learning objectives present (≥3 required)
- 3 exercises present (≥2 required)
- All exercise steps use numbered lists
- Learning objectives use bullet list
- All code blocks carry `[source,<lang>]` annotations (bash, text, json)
- All `[source,bash]` blocks carry `role=execute`
- All images have descriptive, non-filename alt text
- No `xref:` links carry `^`; attribute references used for all URLs (no bare external links)
- All `{attribute}` placeholders resolve against `antora.yml` (`lightwell-console-url`, `java-validated-url`, `python-remediated-url`, etc.)
- All headings sentence-case; no skipped heading levels
- `oc` subcommands lowercase throughout
- No vague marketing terms, unsupported superlatives, non-inclusive language
- Oxford comma present; gender-neutral throughout
- No hardcoded OCP version numbers

---

## Recommended Priority

1. **Add `=== Verify` sections** to all 3 exercises — required for classic Showroom pattern
2. **Fix list nesting** at line 147 — structural/rendering bug
3. **Expand RHDH** at line 193 — first-module acronym expansion requirement
4. **Replace em dashes** at lines 8, 10, 81, 82
5. **Change "two" → "2"** at line 8
6. **Add image link attributes** — lightbox usability (4 images)
