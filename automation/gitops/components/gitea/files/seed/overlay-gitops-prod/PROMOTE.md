# Promote to prod (Track 6.2)

Stage GitOps (`student_gitops_repo_url` → Application `lw-poc-staging`) is
**not** production. Do not retarget Application `lw-poc-prod` at the stage remote.

After Track 5 keyless sign and Track 6.1 unsigned deny:

1. Record the signed app digest (`sha256:` + 64 hex). Do not reuse the
   `REPLACE_ME_PROD_DIGEST` seed string.
2. Tag that image into namespace `lw-poc-prod` (ImageStream), not only stage.
3. In **this** repository, replace `image.digest` and set `replicas: 1`.
4. Commit and push to `student_prod_gitops_repo_url`.
5. Confirm Argo CD Application `lw-poc-prod` is Synced/Healthy and
   `spec.source.repoURL` still ends with `gitops-prod-spring-boot-lw-poc.git`.

Do not put Maven credentials or registry tokens in this repository.
Do not copy PROMOTE.md or values from the stage GitOps remote.
