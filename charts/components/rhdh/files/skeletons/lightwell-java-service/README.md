# ${{ values.name }}

Spring Boot / Java 17 / Maven service scaffolded from the RHDH **lightwell-java-service** Software Template.

Consumes Lightwell Network **Validated** and **Remediated** (`.rhlw-0000X`) Maven streams via `settings.xml` profiles.

## Quick start

```bash
export LIGHTWELL_NEXUS_URL='https://nexus-lightwell-repo.apps.<domain>'
# Optional live LWN / Nexus auth (never commit):
export LW_USERNAME='...'
export LW_PASSWORD='...'

# Module 2 — Validated stream
mvn -s settings.xml -Plightwell-validated clean verify

# Module 3 — Remediated exact-version pin (.rhlw-*)
mvn -s settings.xml -Plightwell-remediated,lightwell-remediated-pins clean verify
```

Remediated pin via Maven profile `lightwell-remediated-pins`: `commons-lang3` `3.14.0.rhlw-00001` (resolve from seeded Nexus / LWN Remediated). Default `<properties>` stay on validated `3.14.0` for Module 2.

## Workshop modules

See [docs/MODULES.md](docs/MODULES.md) for Modules 2–5 mapping (Maven, OSV/`.rhlw-*`, SBOM/RHTPA, pipeline signing + policy).

## Pipeline (RHTAS keyless)

```bash
# Once per namespace: SA + ImageStream for buildah push
oc apply -f .tekton/rbac.yaml
oc apply -f .tekton/pipeline.yaml
# Edit .tekton/pipelinerun.yaml: image-url, Fulcio/Rekor hosts, repo-url
oc create -f .tekton/pipelinerun.yaml
```

Default `maven-profile` is `lightwell-remediated-pins` so `lightwell-dep-gate` (require-remediated) sees `.rhlw-*` in effective POM properties.

Signing uses **cosign keyless** against Red Hat Trusted Artifact Signer (Fulcio/Rekor). Set `cosign-fulcio-url` / `cosign-rekor-url` from `oc -n trusted-artifact-signer get routes` when not using cluster TUF defaults.

Prerequisites that are **not** auto-scaffolded: OpenShift Pipelines Tasks (`git-clone`, `maven`, `buildah`), RHACS Tasks in `stackrox`, pull access to `registry.redhat.io/rhtas/cosign-rhel9`, and Maven Nexus/LWN credentials for the pipeline SA.

## Canonical LWN remotes

- https://packages.redhat.com/lightwell/java/validated
- https://packages.redhat.com/lightwell/java/remediated
- https://packages.redhat.com/lightwell/osv/java/remediated
- https://console.redhat.com/lightwell
