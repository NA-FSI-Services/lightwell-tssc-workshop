# Dev-cluster QA bootstrap (ephemeral RHDP OpenShift claims)
#
# Fill claim.env from the RHDP email (see claim.env.example), then:
#   ./scripts/dev-cluster-login.sh              # OC_TOKEN first
#   ./scripts/dev-cluster-bootstrap.sh
#   ./scripts/dev-cluster-htpasswd.sh           # admin / HTPASSWD_ADMIN_PASSWORD
#   # set OC_LOGIN_MODE=password in claim.env
#   ./scripts/dev-cluster-login.sh              # login as admin
#
# Full runbook: docs/DEV-CLUSTER-BOOTSTRAP.md

| Path | Purpose |
|------|---------|
| `claim.env.example` | Canonical env schema from RHDP emails + HTPasswd vars |
| `claim.env` | Local filled claim (**gitignored**) |
| `*.ca.crt` | Local API CA (**gitignored**) |
| `helm/` | GitOps Subscription + Argo Application for `charts/root-app` |
