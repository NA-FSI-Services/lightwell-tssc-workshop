# Editing Review — Module 05: SBOM Generation and Analysis with RHTPA

**File:** `content/modules/ROOT/pages/module-05-sbom.adoc`
**Review date:** 2026-08-12
**Reviewer:** rhdp-publishing-house:module-reviewer

---

## Summary

| Dimension | Score | Findings |
|-----------|-------|----------|
| Structure | 0.60 | 1 |
| Pedagogy | 0.60 | 1 |
| Style | 0.80 | 3 |
| Technical Accuracy | 0.60 | 1 |
| Formatting | 0.90 | 1 |
| Intro Quality | 1.00 | 0 |
| Demo Structure | 1.00 | 0 |

**Total findings:** 6 (2 High, 2 Medium, 1 Medium-style, 1 Warning)

---

## Findings

### HIGH — Missing `=== Verify` sections in all 5 exercises (B.12)

**Lines:** Throughout  
None of Exercises 0–4 has a dedicated `=== Verify` subsection. Classic Showroom pattern requires explicit verification headings with success criteria. Verification guidance exists but is embedded as inline expected-output prose (e.g., "Expect issuer=…/realms/tpa", "Confirm HTTP 201") rather than dedicated headings.

**Fix:** Add `=== Verify` subsections after each exercise's procedure steps.

---

### HIGH — `[source,bash]` block at line 194 missing `role=execute` (E.3a)

**Line:** 194  
The optional podman/docker command block is annotated `[source,bash]` without `role=execute`. All bash blocks must carry `role=execute` regardless of whether they are flagged optional.

**Fix:** Change to `[source,bash,role=execute]`, or add a NOTE explaining the block is intentionally non-executable in Showroom.

---

### MEDIUM — External link missing `^` new-tab marker (C.3)

**Line:** 337  
Current: `[Red Hat Dependency Analytics]`  
Required: `[Red Hat Dependency Analytics^]`  
All external URLs must open in a new browser tab.

---

### MEDIUM — Em dash in body text (C.6)

**Line:** 8  
`...the same intelligence—without installing an IDE in Showroom.`  
Replace with a comma, parentheses, or rephrase to remove the em dash.

---

### MEDIUM — Em dash in section heading (D.8)

**Line:** 313  
Heading contains `laptop — not required in Showroom`. Em dashes are not permitted in headings.  
**Fix:** Rephrase as `(laptop; not required in Showroom)` or restructure the title.

---

### WARNING — 4 images missing `link=self,window=blank` (C.1)

**Lines:** 72, 114, 301, 343  
- `module-05-tpa-sso-signin.png`
- `module-05-syft-rhtpa-flow.png`
- `module-05-rhtpa-sbom-ui.png`
- `module-05-rhtpa-vs-rhda.png`

**Fix:** Add `link=self,window=blank` to each image macro's attribute list.

---

## Spec Alignment Checks

### SA-1: Outline Coverage — PASS
All outline sections covered: syft installation, CycloneDX generation, SPDX generation, RHTPA SSO auth, API ingestion, UI verification.

### SA-2: Learning Objectives Match — PASS
5 learning objectives present matching outline-defined goals.

### SA-3: Duration Alignment — PASS
Content volume consistent with 20-minute target.

### RS-1: Product Name Accuracy — PASS
SBOM, SLSA, VEX, SPDX, RHTPA, RHDA all expanded on first use at line 8.

### RS-2: Version Consistency — PASS
syft v1.18.1 pin is a third-party tool version, not an OCP attribute; no OCP version strings hardcoded.

---

## Items Verified Clean

- 5 learning objectives present (≥3 required)
- 5 exercises present (≥2 required)
- All exercise procedures use numbered lists; no bullet-formatted steps
- All code blocks carry `[source,<lang>]` annotations; no bare blocks
- `include::partial$student-username-form.adoc[]` resolves correctly
- All images have descriptive, non-generic alt text
- All internal `xref:` links correctly omit `^`
- Keycloak "master realm" (line 69) is a product proper name, not a non-inclusive term — PASS
- No hardcoded cluster URLs, passwords, or usernames; credentials read from cluster ConfigMaps dynamically
- `{RHTPA_BASE}` in `[source,text]` block is display text, not an undefined attribute substitution
- All `oc` subcommands use lowercase
- All other bash blocks carry `role=execute` (except line 194)
- No vague marketing terms, unsupported superlatives, non-inclusive language
- All acronyms expanded on first use; Oxford comma present; gender-neutral throughout
- No deprecated OCP UI navigation paths; all bash/jsonpath/jq/curl syntax valid

---

## Recommended Priority

1. **Add `role=execute` to line 194** — functional issue affecting terminal integration
2. **Add `=== Verify` sections** to all 5 exercises — required for classic Showroom pattern
3. **Fix external link `^` marker** at line 337
4. **Replace em dashes** at lines 8 and 313
5. **Add image link attributes** — lightbox usability (4 images)
