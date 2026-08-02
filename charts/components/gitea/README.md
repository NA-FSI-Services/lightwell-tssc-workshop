# charts/components/gitea — Student Git (Gitea)

In-cluster **Gitea** for learner application repositories. Module 5 pipelines and lab
instructions clone **student** repos here — not the workshop GitOps monorepo
(`NA-FSI-Services/lightwell-tssc-workshop`).

## What it deploys

| Resource | Purpose |
|----------|---------|
| Deployment + PVC + Route `gitea.<domain>` | Gitea (SQLite) |
| Job `gitea-student-repo-seed` | Create admin + student users; push seeded `spring-boot-lw-poc` |
| ConfigMap `demo-userinfo-gitea` | RHDP userinfo (`gitea_url`, `student_repo_url`, credentials) |

Default student: `student` / workshop password → repo `spring-boot-lw-poc` (`pom.xml` at root).

## Sync waves (inside chart)

`namespace` → `rbac` / `config` → `deploy` → `route` → `seed` → `userinfo`

Root-app Application wave: **`15`** (after TSSC operators, before RHDH / sample apps).

## Values of interest

| Key | Default | Notes |
|-----|---------|-------|
| `gitea.namespace` | `gitea` | |
| `students` | one `student` entry | Expand for multi-user claims |
| `seed.repoName` | `spring-boot-lw-poc` | Seeded app repo name |
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
