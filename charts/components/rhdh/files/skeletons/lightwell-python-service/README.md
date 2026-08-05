# Scaffolded by the Lightwell TSSC RHDH Software Template (Showroom Module 7+).
#
# Publishes to in-cluster Gitea as <student_username>/fastapi-lw-poc
# (demo-userinfo-gitea → student_python_repo_url). Never use the workshop GitHub
# monorepo as a learner remote.
#
# Layout at repo root (parity with Gitea seed for Modules 7–9):
#   requirements.txt, pip.conf, pip-remediated.conf, Dockerfile, main.py, .tekton/

## Prerequisites

```bash
export LIGHTWELL_NEXUS_URL='https://nexus-lightwell-repo.apps.<domain>'
export LW_USERNAME='...'   # never commit
export LW_PASSWORD='...'
```

## Pip Validated (Module 7)

```bash
oc -n lightwell-repo extract configmap/lightwell-pip-settings --keys=pip.conf --to=.
# Or rewrite NEXUS_BASE / NEXUS_HOST in this repo's pip.conf
PIP_CONFIG_FILE=$PWD/pip.conf pip install -r requirements.txt
```

## Pip Remediated (Module 8, when enabled)

```bash
oc -n lightwell-repo extract configmap/lightwell-pip-settings --keys=pip-remediated.conf --to=.
PIP_CONFIG_FILE=$PWD/pip-remediated.conf pip install lw-workshop-pypi==1.0.0.rhlw-00001
```

## Pipeline stub (Module 9)

```bash
# Edit .tekton/pipelinerun.yaml: Gitea repo-url (student_python_repo_url), lab image-url
oc apply -f .tekton/rbac.yaml -f .tekton/pipeline.yaml
oc create -f .tekton/pipelinerun.yaml
```

Full Python Tasks (sign / policy / promote) land with workshop issue #149.
See Showroom Module 7+ and [docs/MODULES.md](docs/MODULES.md).
