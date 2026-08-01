# keycloak — workshop IdP for RHTPA

Minimal **Keycloak** (`start-dev` + realm import) that publishes the OIDC issuer RHTPA expects:

`https://sso.<deployer.domain>/realms/tpa`

## Sync waves (inside chart)

| Wave | Resources |
|------|-----------|
| `0` | Namespace `sso` |
| `1` | SA / anyuid SCC, admin Secret, realm ConfigMap |
| `2` | Deployment + Service |
| `3` | Route `sso.<domain>` |
| `4` | RHDP userinfo ConfigMap |

Root-app places this component at sync wave **`5`** so it is up before `rhtpa` (wave `10`).

## Realm clients (must match rhtpa)

| Client | Type | Secret |
|--------|------|--------|
| `frontend` | public | — |
| `cli` | confidential | `workshop-tpa-cli-changeme` (same as `rhtpa.oidc.cliClientSecret`) |

Workshop UI user: `tpa-user` / `workshop-tpa-user-changeme`.

## Values

| Key | Default | Notes |
|-----|---------|-------|
| `keycloak.namespace` | `sso` | Keeps Route host `sso.<domain>` |
| `keycloak.routeHostPrefix` | `sso` | Do not change unless rhtpa `oidc.issuerURL` is overridden |
| `keycloak.image` | `quay.io/keycloak/keycloak:26.0.2` | Quarkus distribution |
| `oidc.cliClientSecret` | `workshop-tpa-cli-changeme` | Keep in sync with rhtpa chart |
| `deployer.domain` | `""` | Injected by root-app |

Override admin / workshop passwords via values or RHDP secret injection — do not use committed defaults in shared environments.

## Local validation

```bash
helm lint charts/components/keycloak
helm template keycloak charts/components/keycloak \
  --set deployer.domain=apps.cluster.example.com
```

## Not in scope

- HA / external DB / production hardening
- RHBK Operator (claim-friendly Deployment instead)
- RHTAS Fulcio Keycloak realm (`trusted-artifact-signer`) — enable separately later if needed
