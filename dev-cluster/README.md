# Dev-cluster QA bootstrap (ephemeral RHDP OpenShift claims)
#
# Fill claim.env from the RHDP email (see claim.env.example), then:
#   ./scripts/dev-cluster-login.sh
#   ./scripts/dev-cluster-bootstrap.sh
#
# Full runbook: docs/DEV-CLUSTER-BOOTSTRAP.md

| Path | Purpose |
|------|---------|
| `claim.env.example` | Canonical env schema from RHDP emails |
| `claim.env` | Local filled claim (**gitignored**) |
| `*.ca.crt` | Local API CA (**gitignored**) |
| `helm/` | GitOps Subscription + Argo Application for `charts/root-app` |
