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

## Notes

- Installs into `openshift-operators` (shared OperatorGroup — do not create another).
- Subscription is skipped at render time if one with the same name already exists (`lookup`).
- Operator provisions the `openshift-pipelines` namespace and webhooks; wait for
  `oc get crd pipelines.tekton.dev` before expecting RHACS Task sync to stick.
