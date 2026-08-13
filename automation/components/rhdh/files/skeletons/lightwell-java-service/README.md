# Scaffolded by the Lightwell TSSC RHDH Software Template (Showroom Module 3).
#
# Publishes to in-cluster Gitea as <student_username>/spring-boot-lw-poc
# (demo-userinfo-gitea → student_repo_url). Never use the workshop GitHub monorepo
# as a learner remote.
#
# Layout at repo root (parity with Gitea seed for Modules 4–6):
#   pom.xml, settings.xml, Dockerfile, src/, tools/osv-eval/, .tekton/

## Prerequisites

```bash
export LIGHTWELL_NEXUS_URL='https://nexus-lightwell-repo.apps.<domain>'
export LW_USERNAME='...'   # never commit
export LW_PASSWORD='...'
export MVN_LOCAL='-Dmaven.repo.local=/tmp/m2'
```

## Maven (Module 3)

```bash
mvn $MVN_LOCAL -s settings.xml -Plightwell-validated clean verify
mvn $MVN_LOCAL -s settings.xml -Plightwell-remediated,lightwell-remediated-pins clean verify
```

## OSV pin (Module 4)

```bash
./tools/osv-eval/scripts/osv-pin.sh tools/osv-eval/samples/LW-DEMO-0001.json
```

## Pipeline (Module 6)

```bash
# Link pull secret for registry.redhat.io/rhtas/cosign-rhel9 — see Module 6 Ex3
# Edit .tekton/pipelinerun.yaml: Gitea repo-url, lab image-url, Fulcio/Rekor
oc apply -f .tekton/rbac.yaml -f .tekton/pipeline.yaml
oc create -f .tekton/pipelinerun.yaml
```

See Showroom Module 3 (scaffold) and Modules 4–6, plus [docs/MODULES.md](docs/MODULES.md).
