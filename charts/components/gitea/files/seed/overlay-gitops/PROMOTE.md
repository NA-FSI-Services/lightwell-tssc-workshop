# Promote (Module 5 Exercise 4)

After a successful signed build in your **lab** namespace:

1. Tag the image into the product namespace ImageStream (see Showroom Ex4 for exact `oc` commands).
2. Read the ImageStream digest (`sha256:…`).
3. Edit `values.yaml`:
   - set `image.digest` to that digest (include the `sha256:` prefix)
   - set `replicas: 1`
4. Commit and push to **this** Gitea gitops remote (not GitHub).
5. Confirm Argo CD Application Synced/Healthy and open the Route.

Do not put Maven credentials or registry tokens in this repository.
