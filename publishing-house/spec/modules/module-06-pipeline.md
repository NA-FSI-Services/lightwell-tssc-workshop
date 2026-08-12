# Module 06 — Pipeline, Signing, Policy, and GitOps Promotion (Java)

### Brief Overview

This is the longest and most complex module in the workshop, closing the full Java trusted supply-chain loop. It combines Tekton pipeline policy gates, RHACS image scanning, keyless image signing via RHTAS (Sigstore Fulcio/Rekor/TUF), and GitOps promotion via Argo CD into a single end-to-end scenario. Learners first trigger a deliberate failure by running the dep-gate pipeline against the un-remediated `pom.xml`, then apply the `.rhlw-00001` fix from Module 4 and rerun to pass. The passing run continues through RHACS image check, syft SBOM upload, and cosign keyless signing. A final GitOps exercise commits the signed image digest to a Helm-based gitops repo, triggering an Argo CD sync to promote the new image to the cluster.

### Audience and Time

- **Personas:** DevSecOps engineers, platform engineers, Java developers
- **Prerequisites for this module:** Modules 1–5 complete; `commons-lang3:3.14.0.rhlw-00001` pin applied in `pom.xml`; cosign binary available; Tekton Pipelines running; RHACS running; Argo CD configured; Gitea gitops repo seeded
- **Estimated duration:** 45 min

### Learning Objectives

- Verify supply-chain policy gates in a Tekton pipeline by triggering and resolving a dependency-gate failure for the Java application
- Sign a container image keylessly using Red Hat Trusted Artifact Signer and verify the signature with cosign
- Promote a signed image digest to a GitOps Helm repository for Argo CD deployment

### Lab Structure

| Section | Title | Duration |
|---------|-------|----------|
| 1 | Architecture: two Pipeline definitions (dep-gate, full build) | 5 min |
| 2 | Exercise 1: Failure path — gate-status=failed | 8 min |
| 3 | Exercise 2: Success path — gate-status=passed | 10 min |
| 4 | Exercise 3: Keyless signing with RHTAS and cosign verification | 12 min |
| 5 | Exercise 4: GitOps promotion via Argo CD | 8 min |
| 6 | End-to-End checklist review | 2 min |

### Detailed Steps

1. Read the pipeline architecture overview: two Tekton Pipeline definitions exist in the `lw-poc-<username>` namespace — the `dep-gate` pipeline (checks `.rhlw-*` pin presence) and the full build pipeline (builds, scans, signs, uploads SBOM).
2. **Exercise 1 — Failure path:** Temporarily revert the `commons-lang3` version in `pom.xml` to `3.14.0` (removing the `.rhlw-00001` suffix) and push the change to Gitea.
3. Trigger the dep-gate pipeline against the un-remediated commit: use `oc create -f <pipelinerun-failure.yaml> -n lw-poc-<username>` or trigger via the OpenShift Console Pipelines view.
4. Watch the PipelineRun in the console or run `oc get pipelineruns -n lw-poc-<username> -w`. Observe the dep-gate Task fail with `gate-status=failed`.
5. Confirm the failure message references the missing `.rhlw-*` pin on `commons-lang3`.
6. **Exercise 2 — Success path:** Restore `pom.xml` to `commons-lang3:3.14.0.rhlw-00001` and push: `git add pom.xml && git commit -m "fix: restore rhlw pin" && git push`.
7. Trigger the dep-gate pipeline again against the remediated commit.
8. Observe the dep-gate Task pass with `gate-status=passed`.
9. The full pipeline continues: RHACS image check Task runs against the built container image — observe it passing in the PipelineRun logs.
10. The syft SBOM upload Task runs — observe the RHTPA ingestion step completing with a 201 response in the Task logs.
11. **Exercise 3 — Keyless signing:** After the image is built and pushed to the OpenShift internal registry, the pipeline Task runs cosign sign with RHTAS (Fulcio CA, Rekor transparency log). Observe the signing step in the PipelineRun.
12. After the PipelineRun completes, verify the signature manually: `cosign verify --certificate-identity-regexp=".*" --certificate-oidc-issuer=<fulcio-issuer> <image-ref>`.
13. Confirm cosign output shows the certificate and transparency log entry from Rekor.
14. **Exercise 4 — GitOps promotion:** Clone the pre-seeded gitops repo: `git clone https://<gitea-url>/<username>/spring-boot-lw-poc-gitops.git`.
15. Update the `values.yaml` in the Helm chart to set the `image.digest` field to the signed image digest from the pipeline output (or from the cosign verify output).
16. Commit and push: `git add values.yaml && git commit -m "chore: promote signed digest <sha>" && git push`.
17. Annotate or sync the Argo CD Application: `oc -n openshift-gitops annotate application/spring-boot-lw-poc-<username> argocd.argoproj.io/refresh=hard`.
18. Open the Argo CD UI and observe the Application syncing and transitioning to **Synced / Healthy**.
19. **End-to-End checklist:** Review the checklist in the module confirming: dep-gate passed, RHACS check passed, SBOM ingested, image signed, GitOps promoted, Argo CD synced.

### Key Takeaways

- The dep-gate Tekton Task enforces the `.rhlw-*` pin as a policy gate — a build that does not use the remediated coordinate cannot pass and cannot be promoted.
- The failure-then-fix pattern is intentional: learners experience the enforcement mechanism, not just the happy path.
- Keyless signing with RHTAS means no long-lived signing keys are managed — identity is asserted via OIDC (the pipeline service account) and recorded in the Rekor transparency log.
- `cosign verify` is the verification step that consumers (RHACS, admission controllers) use to confirm an image was signed by a trusted pipeline identity.
- GitOps promotion via Argo CD means the signed digest — not a mutable tag — is what gets deployed, closing the provenance chain from source commit to running container.
- This module covers the complete TSSC loop for Java; Module 9 mirrors it exactly for Python.

### Infrastructure Notes

- Two Tekton Pipeline definitions must be pre-deployed in `lw-poc-<username>` namespace before the module starts.
- RHACS must be configured with a policy that the pipeline Tasks reference; the check Task must have the RHACS API endpoint and token available.
- RHTAS (Fulcio, Rekor, TUF mirror) must be running and accessible from within the cluster (pipeline pods reach Fulcio for signing).
- Argo CD Application for `spring-boot-lw-poc-<username>` must be pre-created pointing at the learner's gitops Gitea repo.
- cosign binary must be available in the Showroom terminal for the manual verification step.
- The OpenShift BuildConfig or Tekton build Task must push to the internal registry at a path the RHACS check Task knows.
- Gitea gitops repo (`spring-boot-lw-poc-gitops`) must be pre-seeded with a Helm chart stub including a `values.yaml` with an `image.digest` placeholder.
