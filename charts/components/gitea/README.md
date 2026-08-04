# charts/components/gitea — Student Git (Gitea)

In-cluster **Gitea** for learner application **and** GitOps repositories. Module 6
pipelines and lab instructions clone **student** remotes here — not the workshop
GitOps monorepo (`NA-FSI-Services/lightwell-tssc-workshop`). **Do not** send
students to GitHub for lab clone/push; prefer `demo-userinfo-gitea` remotes
everywhere (see [AGENTS.md](../../../AGENTS.md)).

## What it deploys

| Resource | Purpose |
|----------|---------|
| Deployment + PVC + Route `gitea.<domain>` | Gitea (SQLite) |
| Job `gitea-student-repo-seed` | Create admin + student **users**; push **template** trees only |
| ConfigMap script `learner-seed-from-templates.sh` | Learner copies templates → their org repos (Module 2) |
| ApplicationSet `lightwell-student-gitops-sb` | Per-student Argo Apps from learner gitops remotes |
| ConfigMap `demo-userinfo-gitea` | RHDP userinfo (expected URLs, templates, credentials) |

Default student in the **chart**: `student` / workshop password placeholder.

**Dev-cluster bootstrap** overrides to a single **`user1`** with a generated password
(printed by `dev-cluster-bootstrap.sh` / `dev-cluster-workshop-user.sh`). Agents must
capture that password — see [DEV-CLUSTER-WORKSHOP-USER.md](../../../docs/DEV-CLUSTER-WORKSHOP-USER.md).

### Learner model (#120)

1. Lab scripts / charts **start Gitea** and create the student user.
2. In Showroom Module 2, each learner creates organization **`lw-<username>`** and empty repos **`spring-boot-lw-poc`** + **`gitops-spring-boot-lw-poc`**.
3. Learner runs `learner-seed-from-templates.sh` to push operator-prepared content from **`workshop-templates/`** (monorepo isolation) into those repos.
4. Module 3 RHDH `publish:gitea` targets the same learner org (Organizations required upstream).

| Item | Value |
|------|--------|
| Learner org | `lw-<username>` (`student_gitea_org`) |
| App repo | `lw-<user>/spring-boot-lw-poc` |
| GitOps repo | `lw-<user>/gitops-spring-boot-lw-poc` |
| Template org | `workshop-templates` |
| App template | `workshop-templates/spring-boot-lw-poc` |
| GitOps template | `workshop-templates/gitops-spring-boot-lw-poc` |
| RHDH skeleton template | `workshop-templates/lightwell-java-service` (`fetch:template`) |
| Promote NS / Argo app | `lw-poc-<username>` |

## Path isolation (monorepo → template remotes)

Default `seed.source.mode=live`: the seed Job clones the **workshop GitOps URL**
(`seed.source.repoUrl`, injected from root-app `gitops.repoUrl`), then:

1. **App template** — copies `seed.source.path` to `workshop-templates/spring-boot-lw-poc`, includes `tools/osv-eval/`, overlays `.tekton/`
2. **GitOps template** — copies chart tree **excluding `app/`** to `workshop-templates/gitops-spring-boot-lw-poc`

Students never clone GitHub — only Gitea templates + their own org remotes
(`student_repo_url` → `https://gitea.<domain>/lw-<username>/spring-boot-lw-poc.git`).

Optional `seed.source.gitSecretName` references a Secret with `username` / `password`
(or token as password) for private GitOps clones. **Do not commit credentials**; leave
empty for the public development repo.

`SOURCE_MODE=embedded` keeps the legacy ConfigMap pom/README fallback for the **app**
template only (offline chart tests). GitOps seed requires `live` mode.

## Module 6 Ex4 promote (#100)

1. Pipeline builds/signs into **lab** NS (`student-lab`)
2. Student `oc tag`s into `lw-poc-<user>` ImageStream
3. Student commits `image.digest` + `replicas: 1` to Gitea gitops remote
4. ApplicationSet-managed Argo Application syncs → Healthy Route

Monorepo `components.springBootLwPoc` stays **disabled** (runtime SoT is Gitea).

## Sync waves (inside chart)

`namespace` → `rbac` / `config` → `deploy` → `route` → `seed` → `applicationset` → `userinfo`

Root-app Application wave: **`15`** (after TSSC operators, before RHDH / sample apps).

## Values of interest

| Key | Default | Notes |
|-----|---------|-------|
| `gitea.namespace` | `gitea` | |
| `students` | one `student` entry | Expand for multi-user claims |
| `seed.templates.org` | `workshop-templates` | Operator-prepared content |
| `seed.templates.skeleton.enabled` | `true` | Seed RHDH `fetch:template` repo |
| `seed.templates.skeleton.repoName` | `lightwell-java-service` | Under templates org |
| `seed.repoName` | `spring-boot-lw-poc` | Learner + template app name |
| `seed.gitops.enabled` | `true` | Second remote per student |
| `seed.gitops.repoName` | `gitops-spring-boot-lw-poc` | Learner + template gitops name |
| `gitopsAppSet.enabled` | `true` | ApplicationSet in `openshift-gitops` |
| `gitopsAppSet.namespacePrefix` | `lw-poc` | Product NS = `lw-poc-<username>` |
| `seed.source.mode` | `live` | `live` isolate from GitOps repo; `embedded` app fallback |
| `seed.source.repoUrl` | `""` | Injected by root-app from `gitops.repoUrl` |
| `seed.source.path` | `charts/components/spring-boot-lw-poc/app` | App subtree |
| `deployer.domain` | `""` | Injected by root-app |

## Local validation

```bash
helm lint charts/components/gitea
helm template gitea charts/components/gitea \
  --set deployer.domain=apps.cluster.example.com \
  --set seed.source.repoUrl=https://github.com/example/lightwell-tssc-workshop.git
```

## Enable from root-app

```bash
# components.gitea.enabled: true (see charts/root-app/values.yaml)
```
