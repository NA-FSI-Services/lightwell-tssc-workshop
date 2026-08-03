# Fill claim.env from the RHDP email (see claim.env.example), then:
#   ./scripts/dev-cluster-login.sh              # OC_TOKEN first
#   ./scripts/dev-cluster-bootstrap.sh          # scale workers + GitOps + Module 1 + Gitea user1
#   # ↑ capture WORKSHOP LEARNER CREDENTIALS banner (docs/DEV-CLUSTER-WORKSHOP-USER.md)
#   ./scripts/dev-cluster-htpasswd.sh           # admin / HTPASSWD_ADMIN_PASSWORD
#   # set OC_LOGIN_MODE=password in claim.env
#   ./scripts/dev-cluster-login.sh              # login as admin
#
# Full runbook: docs/DEV-CLUSTER-BOOTSTRAP.md
# Workshop learner password: docs/DEV-CLUSTER-WORKSHOP-USER.md

| Path | Purpose |
|------|---------|
| `claim.env.example` | Canonical env schema from RHDP emails + HTPasswd / capacity / `user1` vars |
| `claim.env` | Local filled claim (**gitignored**) |
| `workshop-user.env` | Local `user1` password mirror (**gitignored**) |
| `*.ca.crt` | Local API CA (**gitignored**) |
| `helm/` | GitOps Subscription + Argo Application (`showroom` + `lightwellRepo` + `gitea`) + Argo cluster-admin CRB |
