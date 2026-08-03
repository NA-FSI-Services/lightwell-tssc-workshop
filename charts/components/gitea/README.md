# charts/components/gitea — Student Git (Gitea)

In-cluster **Gitea** for learner application repositories. Module 5 pipelines and lab
instructions clone **student** repos here — not the workshop GitOps monorepo
(`NA-FSI-Services/lightwell-tssc-workshop`). **Do not** send students to GitHub for
lab clone/push; prefer `demo-userinfo-gitea` remotes everywhere (see [AGENTS.md](../../../AGENTS.md)).

## What it deploys

| Resource | Purpose |
|----------|---------|
| Deployment + PVC + Route `gitea.<domain>` | Gitea (SQLite) |
| Job `gitea-student-repo-seed` | Create admin + student users; push seeded `spring-boot-lw-poc` |
| ConfigMap `demo-userinfo-gitea` | RHDP userinfo (`gitea_url`, `student_repo_url`, credentials) |

Default student: `student` / workshop password → repo `spring-boot-lw-poc` (`pom.xml` at root).

## Path isolation (monorepo → student repo)

Default `seed.source.mode=live`: the seed Job clones the **workshop GitOps URL**
(`seed.source.repoUrl`, injected from root-app `gitops.repoUrl`), copies only
`seed.source.path` (default `charts/components/spring-boot-lw-poc/app`) to the
student repo root, then overlays `.tekton/` (hybrid BuildConfig + cosign pipeline)
and a student README.

Students never clone GitHub for lab work — only Gitea remotes from `demo-userinfo-gitea`.

Optional `seed.source.gitSecretName` references a Secret with `username` / `password`
(or token as password) for private GitOps clones. **Do not commit credentials**; leave
empty for the public development repo.

`SOURCE_MODE=embedded` keeps the legacy ConfigMap pom/README fallback for offline
chart tests without git clone.

## Sync waves (inside chart)

`namespace` → `rbac` / `config` → `deploy` → `route` → `seed` → `userinfo`

Root-app Application wave: **`15`** (after TSSC operators, before RHDH / sample apps).

## Values of interest

| Key | Default | Notes |
|-----|---------|-------|
| `gitea.namespace` | `gitea` | |
| `students` | one `student` entry | Expand for multi-user claims |
| `seed.repoName` | `spring-boot-lw-poc` | Seeded app repo name |
| `seed.source.mode` | `live` | `live` isolate from GitOps repo; `embedded` fallback |
| `seed.source.repoUrl` | `""` | Injected by root-app from `gitops.repoUrl` |
| `seed.source.path` | `charts/components/spring-boot-lw-poc/app` | Subtree isolated into Gitea |
| `deployer.domain` | `""` | Injected by root-app |

## Local validation

```bash
helm lint charts/components/gitea
helm template gitea charts/components/gitea \
  --set deployer.domain=apps.cluster.example.com
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
