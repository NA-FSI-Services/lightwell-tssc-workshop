# Editing Review — Module 09: Python Pipeline, Sign, Policy, and GitOps Promotion

**File:** `content/modules/ROOT/pages/module-09-python-pipeline.adoc`
**Review date:** 2026-08-12
**Reviewer:** rhdp-publishing-house:module-reviewer

---

## Summary

| Dimension | Score | Findings |
|-----------|-------|----------|
| Structure | 0.60 | 1 |
| Pedagogy | 0.60 | 1 |
| Style | 0.80 | 5 |
| Technical Accuracy | 0.60 | 2 |
| Formatting | 0.90 | 2 |
| Intro Quality | 1.00 | 0 |
| Demo Structure | 1.00 | 0 |

**Total findings:** 9 (2 High, 4 Medium, 2 Warning, 1 Warning-version)

---

## Findings

### HIGH — `@@LW_USER@@` literal placeholder in executable code blocks (E.4)

**Lines:** 113, 209  
`export STUDENT_USER='@@LW_USER@@'` appears in two `role=execute` blocks. This is not a defined Antora attribute and has no documented Showroom-classic injection mechanism. When learners click execute, the literal string is injected into git URLs, breaking the clone and push commands.

**Fix:** Replace with the Antora attribute defined in `antora.yml`:
```bash
export STUDENT_USER="{student_username}"
```

---

### HIGH — Missing `=== Verify` sections in all 4 exercises (B.12)

**Lines:** Throughout  
None of Exercises 1–4 has a dedicated `=== Verify` subsection. Current pattern embeds verification as numbered sub-steps or inline prose. Classic Showroom requires explicit verification headings.

**Fix:** Add `=== Verify` subsections after each exercise's procedure steps.

---

### MEDIUM — Em dash in prose (C.6 / D.8)

**Line:** 8  
`supply-chain loop—parallel` — replace with a comma or restructure the sentence.

---

### MEDIUM — Broken list nesting at line 186 (C.7)

**Lines:** 186–189  
Bullet list ("Expected log themes:") immediately follows a numbered list item at line 186 with no `+` continuation marker. AsciiDoc creates a disconnected unordered list rather than nested sub-items.

**Fix:** Add a `+` continuation after line 186.

---

### MEDIUM — Number words instead of numerals (D.6)

**Lines:** 58, 493  
- Line 58: `Two related Pipeline definitions exist:` → `2 related Pipeline definitions exist:`
- Line 493: `You have **two** Python Gitea remotes` → `You have **2** Python Gitea remotes`

---

### WARNING — Cosign version hardcoded in download URL (D.10)

**Line:** 418  
`v2.4.3` is hardcoded in the cosign GitHub release URL. No `cosign_version` attribute is defined in `antora.yml`.

**Fix:** Define `cosign_version: 'v2.4.3'` in `antora.yml` and reference it as `{cosign_version}` so the version can be updated without editing module content.

---

### WARNING — 2 images missing `link=self,window=blank` (C.1)

**Lines:** 86, 595  
- `module-09-pipeline-overview.png`
- `module-09-argocd-python-promote.png`

**Fix:** Add `link=self,window=blank` to each image macro.

---

## Spec Alignment Checks

### SA-1: Outline Coverage — PASS
All outline sections covered: Python pipeline architecture, RHACS scan, cosign signing, Argo CD GitOps promotion — mirroring Module 06.

### SA-2: Learning Objectives Match — PASS
4 learning objectives present matching outline-defined goals.

### SA-3: Duration Alignment — PASS
Content volume consistent with 40-minute target.

### RS-1: Product Name Accuracy — PASS
RHACS, RHTAS, TUF all expanded on first use at line 8.

### RS-2: Version Consistency — PASS
No hardcoded OCP version strings. Cosign v2.4.3 noted above — recommend moving to an attribute.

---

## Items Verified Clean

- 4 learning objectives present (≥3 required); 4 exercises present (≥2 required)
- All exercise steps use numbered lists; learning objectives use bullet list
- All code blocks carry `[source,<lang>]` annotations; all bash blocks carry `role=execute`
- `include::partial$student-username-form.adoc[]` resolves correctly
- Both images have descriptive alt text
- All `xref:` links correctly omit `^`; no bare external links without `^`
- No undefined `{attribute}` Antora placeholders
- All headings sentence-case; no skipped heading levels; `oc` subcommands lowercase
- YAML heredocs use consistent 2-space indentation; Python patch script syntactically valid
- Git branch consistently named `main` (not `master`)
- RHACS Central UI reference is RHACS-internal, not an OCP-version-sensitive path
- No vague marketing terms, unsupported superlatives, non-inclusive language
- Oxford comma present; gender-neutral throughout

---

## Recommended Priority

1. **Fix `@@LW_USER@@`** at lines 113 and 209 — breaks git operations for all learners
2. **Add `=== Verify` sections** to all 4 exercises — required for classic Showroom pattern
3. **Fix list nesting** at line 186 — rendering bug
4. **Replace number words** at lines 58 and 493
5. **Add `cosign_version` attribute** to `antora.yml` and update line 418
6. **Replace em dash** at line 8
7. **Add image link attributes** — lightbox usability (2 images)
