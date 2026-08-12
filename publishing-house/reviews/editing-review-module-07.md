# Editing Review — Module 07: PyPI Validated + FastAPI (Python Track Kickoff)

**File:** `content/modules/ROOT/pages/module-07-pypi.adoc`
**Review date:** 2026-08-12
**Reviewer:** rhdp-publishing-house:module-reviewer

---

## Summary

| Dimension | Score | Findings |
|-----------|-------|----------|
| Structure | 0.60 | 1 |
| Pedagogy | 0.60 | 1 |
| Style | 0.80 | 3 |
| Technical Accuracy | 1.00 | 0 |
| Formatting | 0.90 | 1 |
| Intro Quality | 1.00 | 0 |
| Demo Structure | 1.00 | 0 |

**Total findings:** 4 (1 High, 2 Medium, 1 Warning-heading, 1 Warning-images)

This is one of the cleaner modules — technical accuracy is perfect.

---

## Findings

### HIGH — Missing `=== Verify` sections in all 6 exercises (B.12)

**Lines:** 83, 137, 179, 226, 257, 280  
None of Exercises 1–6 has a dedicated `=== Verify` subsection. Classic Showroom pattern requires explicit verification headings. "Expected:", "Confirm:", and "Quick package check" prose exist but do not satisfy the structural requirement.

**Fix:** Add `=== Verify` subsections after each exercise's procedure steps.

---

### MEDIUM — Em dashes throughout prose and headings (C.6 / D.8)

**Lines:** 52, 83, 137, 179, 216, 226, 257, 280, 331, 332 (10 instances)  
Em dashes appear in exercise headings (lines 83, 137, 179, 226, 257, 280) and body prose.

**Fix in exercise headings:** Replace ` — ` with `: ` (e.g., `== Exercise 1: Configure pip.conf`).  
**Fix in prose:** Replace with a comma, colon, or restructured sentence.

---

### WARNING — Heading capitalization (C.9)

**Line:** 312  
`== Relationship to Modules 2–3 (Java)` — "Modules" should be lowercase:  
→ `== Relationship to modules 2–3 (Java)`

---

### WARNING — 2 images missing `link=self,window=blank` (C.1)

**Lines:** 81, 149  
- `module-07-pypi-validated-nexus.png`
- `module-07-gitea-python-repos.png`

**Fix:** Add `link=self,window=blank` to each image macro.

---

## Spec Alignment Checks

### SA-1: Outline Coverage — PASS
All outline sections covered: pip.conf configuration, Validated PyPI tier, Gitea repo setup, FastAPI scaffolding via RHDH, Python track orientation.

### SA-2: Learning Objectives Match — PASS
4 learning objectives present matching outline-defined goals.

### SA-3: Duration Alignment — PASS
Content volume consistent with 30-minute target.

### RS-1: Product Name Accuracy — PASS
RHDH, RHTPA, SBOM expanded in prior modules per module sequence; all URL attributes use defined antora.yml values.

### RS-2: Version Consistency — PASS
No hardcoded OCP version strings; `httpx==0.27.2` is a package pin in a code block (expected), not a platform version mismatch.

---

## Items Verified Clean

- 4 learning objectives present (≥3 required); 6 exercises present (≥2 required)
- Numbered lists used for enumerated steps; no bullet-based procedure steps
- All code blocks carry `[source,bash]` headers; all bash blocks carry `role=execute`
- `include::partial$student-username-form.adoc[]` resolves correctly
- Both images have descriptive alt text
- All `xref:` links correctly omit `^`; no bare external links without `^`
- All Python URL attributes (`{python-validated-url}`, `{python-remediated-url}`, `{python-validated-simple-url}`, `{python-remediated-simple-url}`) defined in `antora.yml`
- No hardcoded cluster URLs, usernames, or passwords; URLs obtained from ConfigMap lookups
- All headings sentence-case (except line 312 noted above); no skipped heading levels
- `oc` subcommands lowercase throughout; all bash/shell examples syntactically valid
- No vague marketing terms, unsupported superlatives, non-inclusive language
- Gender-neutral `you/your` throughout; Oxford comma present

---

## Recommended Priority

1. **Add `=== Verify` sections** to all 6 exercises — required for classic Showroom pattern
2. **Replace em dashes** in exercise headings (6) and prose (4) — use `:` in headings, comma/restructure in prose
3. **Fix "Modules" → "modules"** at line 312
4. **Add image link attributes** — lightbox usability (2 images)
