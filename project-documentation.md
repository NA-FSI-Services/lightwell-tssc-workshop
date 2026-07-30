# Lightwell TSSC Workshop — project notes

Workshop GitOps content for RHDP (`agd-v2.ocp-field-asset-cnv.prod`), bootstrapped from the field-sourced-content template.

## Canonical docs

| Doc | Purpose |
|-----|---------|
| [README.md](./README.md) | Repository purpose and quick orientation |
| [DEVELOPMENT-PLAN.md](./DEVELOPMENT-PLAN.md) | Phases, LWN lab model, GitHub Project / issues |
| [AGENTS.md](./AGENTS.md) | Rules for coding agents |
| [docs/repository-conventions.md](./docs/repository-conventions.md) | Helm App-of-Apps vs Ansible paths; rhpds transfer |

## Platform integration (from template)

| Path | Purpose |
|------|---------|
| `roles/ocp4_workload_field_content/` | AgnosticD field-content workload role |
| `examples/helm/` | App-of-Apps reference (not long-term production sync path) |
| `examples/ansible/` | ansible-runner Job reference |

Production charts: `charts/root-app` + `charts/components/*`.

## Variable naming

AgnosticD workload variables keep the `ocp4_workload_` prefix when touching the field-content role:

- ✅ `ocp4_workload_field_content_gitops_repo_url`
- ❌ `field_content_gitops_repo_url`

## RHDP labels

- Health: `demo.redhat.com/application: "lightwell-tssc-workshop"`
- Userinfo ConfigMaps: `demo.redhat.com/userinfo: ""`
