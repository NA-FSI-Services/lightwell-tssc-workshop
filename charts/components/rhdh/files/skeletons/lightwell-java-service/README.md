# ${{ values.name }}

Scaffolded by the Lightwell TSSC RHDH Software Template (**optional** advanced path).

For Module 5 Ex3, prefer the **Gitea-seeded** `spring-boot-lw-poc` student repository
from `demo-userinfo-gitea`. If you use this template, push to **Gitea** — do not use
GitHub as the learner remote.

## Local Maven (optional)

```bash
export LIGHTWELL_NEXUS_URL='https://nexus-lightwell-repo.apps.<domain>'
export LW_USERNAME='...'   # never commit
export LW_PASSWORD='...'
mvn -s settings.xml -Plightwell-validated clean verify
```

Remediated pin via Maven profile `lightwell-remediated-pins`: `commons-lang3`
`3.14.0.rhlw-00001`. Dep-gate reads **default** POM properties — update those for the
pipeline pass path.

## Pipeline (hybrid BuildConfig + RHTAS)

```bash
oc new-project <lab-ns> 2>/dev/null || oc project <lab-ns>
# Link pull secret for registry.redhat.io/rhtas/cosign-rhel9 — see Module 5 Ex3
oc apply -f .tekton/rbac.yaml
oc apply -f .tekton/pipeline.yaml
# Edit .tekton/pipelinerun.yaml: Gitea repo-url, lab image-url, Fulcio/Rekor
oc create -f .tekton/pipelinerun.yaml
```

Graph: clone → `lightwell-dep-gate` → OpenShift Binary BuildConfig → ACS (soft-skip OK) →
SBOM → cosign keyless. No buildah. Image stays in the learner lab namespace.

See Showroom Module 5 and [docs/MODULES.md](docs/MODULES.md).
