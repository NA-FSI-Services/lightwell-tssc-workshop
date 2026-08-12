# Module 09 — Python Pipeline, Sign, Policy, and GitOps Promotion

### Brief Overview

This module closes the Python trusted supply-chain loop by mirroring Module 6 exactly for the FastAPI application. Learners run the `lightwell-python-dep-gate` Tekton task in failure mode (by removing the `+rhlw.*` pin from `requirements.txt`), restore the pin to achieve a passing gate, sign the resulting container image keylessly via RHTAS, and promote the signed digest to the Python GitOps Helm repo for Argo CD sync. A Java vs. Python comparison table at the end of the module summarizes the structural equivalences between the two tracks, reinforcing the pattern-based approach that Lightwell Network enables across ecosystems.

### Audience and Time

- **Personas:** Python developers, DevSecOps engineers, platform engineers
- **Prerequisites for this module:** Modules 7 and 8 complete; `lw-fastapi` repo with `+rhlw.00001` pin committed and pushed to Gitea; `lw-fastapi-gitops` Gitea repo seeded with Helm chart stub; Tekton Pipelines running; RHACS running; RHTAS running; Argo CD Application for `lw-fastapi-<username>` pre-created
- **Estimated duration:** 40 min

### Learning Objectives

- Verify supply-chain policy gates in a Tekton pipeline by triggering and resolving a dependency-gate failure for the Python FastAPI application
- Sign a FastAPI container image keylessly using Red Hat Trusted Artifact Signer and verify the signature with cosign
- Promote a signed Python image digest to a GitOps Helm repository for Argo CD deployment

### Lab Structure

| Section | Title | Duration |
|---------|-------|----------|
| 1 | Exercise 1: Failure path — remove +rhlw.* pin → gate-status=failed | 8 min |
| 2 | Exercise 2: Success path — restore pin → gate-status=passed | 10 min |
| 3 | Exercise 3: Keyless sign and verify with RHTAS/cosign | 10 min |
| 4 | Exercise 4: GitOps promotion via Argo CD (Python) | 8 min |
| 5 | Java vs. Python comparison table | 2 min |
| 6 | End-to-End checklist review | 2 min |

### Detailed Steps

1. **Exercise 1 — Failure path:** Open `requirements.txt` in the `lw-fastapi` repo. Remove the `+rhlw.00001` local version label from `lw-workshop-pypi` so it reads `lw-workshop-pypi==1.0.0` (without the local segment).
2. Commit and push: `git add requirements.txt && git commit -m "test: remove rhlw pin to trigger gate failure" && git push`.
3. Trigger the `lightwell-python-dep-gate` Tekton task: `oc create -f <python-pipelinerun-failure.yaml> -n lw-fastapi-<username>` or trigger via the OpenShift Console Pipelines view.
4. Watch the PipelineRun: `oc get pipelineruns -n lw-fastapi-<username> -w`. Observe the dep-gate Task fail with `gate-status=failed`.
5. Confirm the failure message references the missing `+rhlw.*` local version label on `lw-workshop-pypi`.
6. **Exercise 2 — Success path:** Restore `requirements.txt`: `lw-workshop-pypi==1.0.0+rhlw.00001`. Commit and push: `git add requirements.txt && git commit -m "fix: restore rhlw pin" && git push`.
7. Trigger the `lightwell-python-dep-gate` pipeline again against the restored commit.
8. Observe `gate-status=passed` in the PipelineRun Task logs.
9. The full pipeline continues: RHACS image check Task runs against the FastAPI container image — observe it passing.
10. The syft SBOM upload Task runs — observe RHTPA ingestion completing with a 201 response in the Task logs.
11. **Exercise 3 — Keyless signing:** The pipeline signing Task runs cosign sign against the FastAPI image using RHTAS (Fulcio CA, Rekor transparency log). Observe the signing step in the PipelineRun logs.
12. After the PipelineRun completes, verify the signature manually: `cosign verify --certificate-identity-regexp=".*" --certificate-oidc-issuer=<fulcio-issuer> <fastapi-image-ref>`.
13. Confirm cosign output shows the certificate and Rekor transparency log entry. Note: the signing certificate identity will reference the Tekton pipeline service account, not a human identity.
14. **Exercise 4 — GitOps promotion (Python):** Clone the seeded gitops repo: `git clone https://<gitea-url>/<username>/lw-fastapi-gitops.git`.
15. Run the provided Python patch script to update `values.yaml` with the signed image digest: `python3 patch-values.py --digest <sha256:...> values.yaml` (or manually edit `image.digest` in `values.yaml`).
16. Commit and push: `git add values.yaml && git commit -m "chore: promote signed Python digest <sha>" && git push`.
17. Sync the Argo CD Application: `oc -n openshift-gitops annotate application/lw-fastapi-<username> argocd.argoproj.io/refresh=hard`.
18. Open the Argo CD UI and observe the Python application (`lw-fastapi-<username>`) syncing and reaching **Synced / Healthy**.
19. **Java vs. Python comparison table:** Review the table in the module listing the structural equivalences: pom.xml → requirements.txt, `.rhlw-*` suffix → `+rhlw.*` local label, `lightwell-java-service` → `lightwell-python-service`, `dep-gate` pipeline → `lightwell-python-dep-gate` pipeline, `spring-boot-lw-poc-gitops` → `lw-fastapi-gitops`.
20. **End-to-End checklist:** Confirm all items: dep-gate passed, RHACS check passed, SBOM ingested, image signed, GitOps promoted, Argo CD synced.

### Key Takeaways

- The `lightwell-python-dep-gate` Tekton task enforces the `+rhlw.*` PEP 440 local label as a policy gate — the Python gate is structurally identical to the Java gate, only the version format changes.
- The fail-then-fix pattern in this module is the direct parallel to Module 6 Exercise 1 and 2 — experiencing the enforcement mechanism in both ecosystems reinforces the pattern.
- Keyless signing, cosign verification, and Argo CD GitOps promotion are identical across Java and Python — the TSSC toolchain is language-agnostic above the build-tool layer.
- The Java vs. Python comparison table makes the ecosystem-specific differences explicit: only the dependency manifest format and version label syntax differ; the architecture is the same.
- After completing Module 9, learners have demonstrated the complete Lightwell TSSC loop end-to-end for two ecosystems — proving the pattern scales across language boundaries.

### Infrastructure Notes

- `lightwell-python-dep-gate` Tekton Pipeline definition must be pre-deployed in `lw-fastapi-<username>` namespace.
- RHACS policy for Python images must be configured (same or parallel policy to the Java check in Module 6).
- RHTAS must be running — same instance used in Module 6; no additional configuration needed for Python.
- Argo CD Application `lw-fastapi-<username>` must be pre-created pointing at `lw-fastapi-gitops` Gitea repo.
- The Python patch script `patch-values.py` must be pre-staged in the `lw-fastapi-gitops` repo or Showroom home.
- cosign binary must be available in the Showroom terminal (same binary as Module 6).
- GitOps Helm chart stub in `lw-fastapi-gitops` must include `image.digest` placeholder in `values.yaml`.
