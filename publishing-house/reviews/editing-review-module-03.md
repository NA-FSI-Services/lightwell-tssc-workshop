# Editing Review — Module 03: Developer Hub Scaffolding (Java Golden Path)

**File:** `content/modules/ROOT/pages/module-03-scaffold.adoc`
**Review date:** 2026-08-12
**Reviewer:** rhdp-publishing-house:module-reviewer

---

## Summary

| Dimension | Score | Findings |
|-----------|-------|----------|
| Structure | 0.60 | 1 |
| Pedagogy | 0.60 | 1 |
| Style | 0.80 | 2 |
| Technical Accuracy | 1.00 | 0 |
| Formatting | 0.90 | 2 |
| Intro Quality | 1.00 | 0 |
| Demo Structure | 1.00 | 0 |

**Total findings:** 5 (2 High, 2 Medium, 1 Warning)

---

## Findings

### HIGH — Missing `=== Verify` sections in all 4 exercises (B.12)

**Lines:** Throughout  
None of Exercises 1–4 contains a dedicated `=== Verify` subsection. Classic Showroom pattern requires explicit verification headings. Current verification is embedded as inline prose (`Expect HTTP 204`, URL-match statements) or folded into execution sub-sections (`=== Validated resolution + consumption`).

**Fix:** Add a `=== Verify` block to each exercise with observable success criteria. Example for Exercise 2:

```asciidoc
=== Verify

A `204` response confirms the repository was deleted.
A `404` means it was already absent — either is safe to proceed.

[source,bash,role=execute]
----
curl -sk -o /dev/null -w "%{http_code}\n" -u "${STUDENT_USER}:${STUDENT_PASS}" \
  "${GITEA_URL}/api/v1/repos/${GITEA_ORG}/${STUDENT_REPO_NAME}"
----

Expect `404`.
```

---

### HIGH — 2 referenced image files are missing from the repository (IMG.1)

**Lines:** 89, 123  
The following image files do not exist anywhere under `content/`:
- `module-03-gitea-delete-repo.png`
- `module-03-rhdh-scaffold-form.png`

Only `content/modules/ROOT/images/showroom-preview.png` exists. These will render as broken images in Showroom.

**Fix:** Add the PNG screenshots to `content/modules/ROOT/assets/images/`.

---

### MEDIUM — Em dashes throughout prose and headings (C.6 / D.8)

**Lines:** 8, 44, 79, 105, 112, 131 (6 instances)  
Em dashes (—) appear in body text and exercise headings.

**Fix:** In exercise headings (`== Exercise N — Title`), replace ` — ` with `: ` (e.g., `== Exercise 1: Discover RHDH and Gitea URLs`). In body text (lines 8, 105), replace with a comma or semicolon.

---

### WARNING — 2 images missing `link=self,window=blank` (C.1)

**Lines:** 89, 123  
Both `image::` macros lack the lightbox attributes. (Also note: the referenced files are missing — fix IMG.1 first.)

**Fix:** Add `link=self,window=blank` to both image macros once the files are added.

---

## Spec Alignment Checks

### SA-1: Outline Coverage — PASS
All outline sections covered: RHDH URL discovery, Gitea repo cleanup, Software Template scaffolding, clone and verify build.

### SA-2: Learning Objectives Match — PASS
5 learning objectives present matching outline-defined goals.

### SA-3: Duration Alignment — PASS
Content volume consistent with 25-minute target.

### RS-1: Product Name Accuracy — PASS
RHDH expanded as "Red Hat Developer Hub (RHDH)" on first use at line 8.

### RS-2: Version Consistency — PASS
No hardcoded OCP version strings.

---

## Items Verified Clean

- 5 learning objectives present (≥3 required)
- 4 exercises present (≥2 required)
- Exercise steps use ordered lists or prose + code blocks; no bullet-based steps
- All code blocks carry `[source,<lang>]` annotations; all bash blocks carry `role=execute`
- `include::partial$student-username-form.adoc[]` resolves correctly
- All images have descriptive alt text
- All `xref:` links correctly omit `^`; no bare external links without `^`
- All headings sentence-case; no skipped heading levels
- `oc` subcommands lowercase throughout
- `@@LW_USER@@` at line-level is a form-driven JS substitution from the partial, not a hardcoded literal
- All attribute references use defined attributes from `antora.yml`
- No vague marketing terms, unsupported superlatives, non-inclusive language
- RHDH expanded on first use; Oxford comma present; gender-neutral throughout

---

## Recommended Priority

1. **Add missing image files** (`module-03-gitea-delete-repo.png`, `module-03-rhdh-scaffold-form.png`) — broken images in all deployments
2. **Add `=== Verify` sections** to all 4 exercises — required for classic Showroom pattern
3. **Replace em dashes** in headings and prose (6 instances)
4. **Add image link attributes** — lightbox usability (after images are added)
