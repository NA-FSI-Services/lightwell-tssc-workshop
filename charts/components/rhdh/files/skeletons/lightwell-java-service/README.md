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

Default remediated pin in `pom.xml`: `commons-lang3` `3.14.0.rhlw-00001` (resolve from seeded Nexus / LWN Remediated).

## Workshop modules

See [docs/MODULES.md](docs/MODULES.md) for Modules 2–5 mapping (Maven, OSV/`.rhlw-*`, SBOM/RHTPA, pipeline signing + policy).

## Pipeline (RHTAS keyless)

```bash
oc apply -f .tekton/pipeline.yaml
# Edit .tekton/pipelinerun.yaml image/repo params, then:
oc create -f .tekton/pipelinerun.yaml
```

Signing uses **cosign keyless** against Red Hat Trusted Artifact Signer (Fulcio/Rekor). Provide Fulcio/Rekor URLs from the RHTAS chart when not using cluster TUF defaults.

## Canonical LWN remotes

- https://packages.redhat.com/lightwell/java/validated
- https://packages.redhat.com/lightwell/java/remediated
- https://packages.redhat.com/lightwell/osv/java/remediated
- https://console.redhat.com/lightwell
