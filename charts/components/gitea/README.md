# charts/components/gitea — Student Git (Gitea)

In-cluster **Gitea** for learner application **and** GitOps repositories. Module 5
pipelines and lab instructions clone **student** remotes here — not the workshop
GitOps monorepo (`NA-FSI-Services/lightwell-tssc-workshop`). **Do not** send
students to GitHub for lab clone/push; prefer `demo-userinfo-gitea` remotes
everywhere (see [AGENTS.md](../../../AGENTS.md)).

## What it deploys

| Resource | Purpose |
|----------|---------|
| Deployment + PVC + Route `gitea.<domain>` | Gitea (SQLite) |
| Job `gitea-student-repo-seed` | Create admin + students; push app + gitops seeds |
| ApplicationSet `lightwell-student-gitops-sb` | Per-student Argo Apps from public Gitea gitops remotes |
| ConfigMap `demo-userinfo-gitea` | RHDP userinfo (app + gitops URLs, promote NS, credentials) |

Default student in the **chart**: `student` / workshop password placeholder.

**Dev-cluster bootstrap** overrides to a single **`user1`** with a generated password
(printed by `dev-cluster-bootstrap.sh` / `dev-cluster-workshop-user.sh`). Agents must
capture that password — see [DEV-CLUSTER-WORKSHOP-USER.md](../../../docs/DEV-CLUSTER-WORKSHOP-USER.md).

Per seeded student (chart default or bootstrap override):

* App repo: `spring-boot-lw-poc` (`pom.xml` + `.tekton/` at root)
* GitOps repo: `gitops-spring-boot-lw-poc` (thin Helm chart, **no** `./app`)
* Promote NS / Argo app: `lw-poc-<username>` (e.g. `lw-poc-user1` on claims)

## Path isolation (monorepo → student remotes)

Default `seed.source.mode=live`: the seed Job clones the **workshop GitOps URL**
(`seed.source.repoUrl`, injected from root-app `gitops.repoUrl`), then:

1. **App repo** — copies `seed.source.path` (default `charts/components/spring-boot-lw-poc/app`) to repo root + overlays `.tekton/`
2. **GitOps repo** (`seed.gitops.enabled`) — copies `seed.gitops.sourcePath` chart tree **excluding `app/`**, overlays README/PROMOTE.md

Students never clone GitHub for lab work — only Gitea remotes from `demo-userinfo-gitea`.

Optional `seed.source.gitSecretName` references a Secret with `username` / `password`
(or token as password) for private GitOps clones. **Do not commit credentials**; leave
empty for the public development repo.

`SOURCE_MODE=embedded` keeps the legacy ConfigMap pom/README fallback for the **app**
repo only (offline chart tests). GitOps seed requires `live` mode.

## Module 5 Ex4 promote (#100)

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
| `seed.repoName` | `spring-boot-lw-poc` | Seeded app repo name |
| `seed.gitops.enabled` | `true` | Second remote per student |
| `seed.gitops.repoName` | `gitops-spring-boot-lw-poc` | Thin chart remote |
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
helm template lightwell charts/root-app \
  --set components.gitea.enabled=true \
  --set deployer.domain=apps.cluster.example.com
```

## Related

- Module 5 Showroom: `docs/modules/ROOT/pages/module-05-pipeline.adoc`
- RHACS policy lab ConfigMap uses `pipelineHooks.labRepoUrl` from root-app when Gitea is enabled
