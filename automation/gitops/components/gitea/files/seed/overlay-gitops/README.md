# Student GitOps repository (Module 5 Exercise 4)

This Gitea repo is your **runtime desired state** for the Spring Boot LWN PoC.

- Chart root is a thin Helm chart (no `./app` Maven sources — those live in your
  `spring-boot-lw-poc` application repo used by the pipeline).
- Default `replicas: 0` and empty `image.digest` keep Argo CD **Healthy** before promote.
- `admission/trust-policy.yaml` is the Track 6.1 scored file (V2-16). Seed is
  `enforce: false` with `REPLACE_ME_*`. Do not apply `kind: ClusterImagePolicy`.
- Exercise 4: `oc tag` the signed image into your product namespace ImageStream, commit
  `image.digest` + `replicas: 1`, push here, let Argo CD sync.

See `PROMOTE.md` for the promote steps. Discover URLs from ConfigMap `demo-userinfo-gitea`
(`student_gitops_repo_url`, `student_promote_namespace`).
