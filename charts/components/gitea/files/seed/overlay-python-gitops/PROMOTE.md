# Promote (Module 9)

After a successful signed build in your **lab** namespace:

1. Tag the image into the product namespace ImageStream (see Showroom Module 9 for exact `oc` commands).
2. Read the ImageStream digest (`sha256:…`).
3. Edit `values.yaml`:
   - set `image.digest` to that digest (include the `sha256:` prefix)
   - set `replicas: 1`
4. Commit and push to **this** Gitea gitops remote.
5. Confirm Argo CD Application Synced/Healthy and open the Route.

Do not put PyPI credentials or registry tokens in this repository.
