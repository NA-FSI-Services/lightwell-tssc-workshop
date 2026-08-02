# spring-boot-lw-poc (student lab repository)

Learner-owned application repository for the Lightwell TSSC workshop.

Use this repository for Module 5 pipeline exercises (clone → policy gate → remediate → re-run).
Do **not** clone or push to the workshop GitOps monorepo.

## Module 5 quick path

1. Confirm the default pin fails the dep gate:

   ```xml
   <commons.lang3.version>3.14.0</commons.lang3.version>
   ```

2. For the success path, change the **default** properties pin (not only a profile) to:

   ```xml
   <commons.lang3.version>3.14.0.rhlw-00001</commons.lang3.version>
   ```

3. Commit, push to `main`, and re-run Pipeline `lightwell-build-policy-gate` with
   `repo-url` pointing at **this** repository and `pom-path=pom.xml`.
