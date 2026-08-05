# Student FastAPI GitOps repository (Module 9 promote)

This Gitea repo is your **runtime desired state** for the FastAPI LWN PoC.

- Chart root is a thin Helm chart (no `./app` Python sources — those live in your
  `fastapi-lw-poc` application repo used by the pipeline).
- Default `replicas: 0` and empty `image.digest` keep Argo CD **Healthy** before promote.
- Module 9: `oc tag` the signed image into your product namespace ImageStream, commit
  `image.digest` + `replicas: 1`, push here, let Argo CD sync.

See `PROMOTE.md` for the promote steps. Discover URLs from ConfigMap `demo-userinfo-gitea`
(`student_python_gitops_repo_url`).
