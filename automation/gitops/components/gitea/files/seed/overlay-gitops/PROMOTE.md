# Promote (Module 5 Exercise 4)

After a successful signed build in `lw-poc-build` (`student_build_namespace`):

1. Tag the image into the product namespace ImageStream (see Showroom 6.1 for exact `oc` commands).
2. `cosign copy` the build ImageStream to the dest digest, then `cosign sign --key` the dest (oc tag does not copy `.sig` tags).
3. Read the ImageStream digest (`sha256:…`).
4. Edit `values.yaml`:
   - set `image.digest` to that digest (include the `sha256:` prefix)
   - set `replicas: 1`
5. Commit and push to **this** Gitea gitops remote.
6. Confirm Argo CD Application Synced/Healthy and open the Route.

Do not put Maven credentials or registry tokens in this repository.
