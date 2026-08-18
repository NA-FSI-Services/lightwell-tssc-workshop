# charts/components/pipelines

OLM **Subscription** for Red Hat OpenShift Pipelines (`openshift-pipelines-operator-rh`).

## Why

Module 5 student `.tekton/` overlays and RHACS chart Tasks/Pipelines need Tekton CRDs
(`pipelines.tekton.dev`, `tasks.tekton.dev`, …). Bare OCP claims do not ship Pipelines;
catalog / AgnosticV should enable this component with the Module 4–5 stack.

## Sync order

Root-app places this Application at **wave 8** (after Keycloak wave 5, before
`rhtas` / `rhtpa` / `rhacs` wave 10) so CRDs exist before RHACS Tekton resources sync.

## Enable

```bash
# Via root-app values / Argo Application valuesObject:
components.pipelines.enabled=true
```

## V2-14 verify-base-image

Task `verify-base-image` in namespace `lightwell-tasks` checks cosign signature,
attestation, and SBOM **before** BuildConfig. It is **not** referenced from the
seeded learner Pipeline (`spring-boot-lw-poc-build-sign`). Wire it in Gitea
`.tekton/pipeline.yaml`. Identity/issuer stay `REPLACE_ME_*` until the learner
passes Red Hat's published Hummingbird signer (do not invent; do not paste
`example-pipeline-snippet.yaml` from ConfigMap `verify-base-image-docs`).

Image build stays **OpenShift BuildConfig**.

Cluster resolver for this Task is the same pattern as RHACS Tasks in `stackrox`
(`kind=task`, `namespace=lightwell-tasks`).

## V2-15 conforma-policy

Task `conforma-policy` in namespace `lightwell-tasks` runs `ec validate image`
against a **local** policy file from a ConfigMap. It is **not** referenced from
the seeded learner Pipeline. Wire it in Gitea `.tekton/pipeline.yaml` so it
runs **after** `cosign-sign-keyless`.

ConfigMap `conforma-policy` is the too-permissive seed (`skip-image-sig-check=true`,
CVE threshold `999`, identity `.*`, all workshop rules excluded). Argo reverts
edits to that object — copy it to `lw-poc-student`, tighten the copy, and pass
`policy-namespace` / `policy-configmap`. Fail path: unsigned `FROM`. Pass path:
learner-signed app image. Do not copy `example-pipeline-snippet.yaml` from
ConfigMap `conforma-policy-docs`. Do not fetch policy from quay.io or GitHub.

Image build stays **OpenShift BuildConfig**.

## Notes

- Installs into `openshift-operators` (shared OperatorGroup — do not create another).
- Subscription is skipped at render time if one with the same name already exists (`lookup`).
- Operator provisions the `openshift-pipelines` namespace and webhooks; wait for
  `oc get crd pipelines.tekton.dev` before expecting RHACS Task sync to stick.
