# charts/components/rhtpa — Red Hat Trusted Profile Analyzer

Deploys Trusted Profile Analyzer for the Lightwell TSSC workshop via the **RHTPA Operator** (namespace-scoped OLM Subscription) and a `TrustedProfileAnalyzer` custom resource. Supports **CycloneDX SBOM** upload and **VEX / advisory** importer feeds (CVE, OSV; optional Red Hat CSAF / SBOM mirrors).

## Sync waves (inside this chart)

| Wave | Resources |
|------|-----------|
| `0` | Namespace (`trusted-profile-analyzer`) |
| `1` | OperatorGroup + Subscription |
| `2` | PostgreSQL + OIDC CLI secret |
| `3` | `TrustedProfileAnalyzer` CR |
| `4` | Job `rhtpa-oidc-wait` (wait Keycloak OIDC; roll `server` if not Ready) |
| `5` | Ingestion-info + RHDP userinfo ConfigMaps |

Root App-of-Apps places this chart at sync wave **`10`** (with other TSSC operators).

## SBOM and VEX / advisory flows

| Flow | How |
|------|-----|
| **CycloneDX SBOM** | Learner/`syft` upload via TPA UI or REST API (`supported_cyclonedx_version` in values / ingestion ConfigMap) |
| **VEX / advisories** | Importers: `cve` (CVE list v5), `osv-github` (OSV); optional `redhat-csaf` |
| **Red Hat SBOM mirror** | Optional `redhat-sboms` importer (disabled by default — heavy) |
| **RHDA shift-left** | IDE client of TPA intelligence — see [docs/rhda-rhtpa-shift-left.md](../../../docs/rhda-rhtpa-shift-left.md) (Showroom = TPA UI/`syft` only; no IDE in-cluster) |

Storage defaults to **filesystem** (PVC) for PoC / RHDP workshops. Prefer S3 / OpenShift Data Foundation for production-like sizing.

## Prerequisites

- **OIDC** (Keycloak / RHBK) realm matching `oidc.realm` with `frontend` and `cli` clients — chart derives `https://sso.<deployer.domain>/realms/<realm>`
- Workshop IdP: enable `components.keycloak` (wave 5) in root-app — see [`charts/components/keycloak`](../keycloak/); keep `oidc.cliClientSecret` in sync with that chart
- Job `rhtpa-oidc-wait` waits for `…/realms/tpa/.well-known/openid-configuration` and rolls Deployment `server` only when not Ready (avoids CrashLoop when TPA syncs before Keycloak)
- Override workshop defaults for `postgresql.password` and `oidc.cliClientSecret` via values or RHDP secret injection (**do not use committed defaults in shared environments**)

## Reuse sources

- RHADS / `rhpds.build-secured-dev-workflows` `trusted_profile_analyzer` role
- [RHTPA Deployment Guide](https://docs.redhat.com/en/documentation/red_hat_trusted_profile_analyzer/2/html-single/deployment_guide/index)

## Values of interest

| Key | Default | Notes |
|-----|---------|-------|
| `rhtpa.enabled` | `true` | Chart gate |
| `rhtpa.namespace` | `trusted-profile-analyzer` | Instance + operator NS |
| `operator.channel` | `stable-v3` | Catalog default; `stable-v1.1` also exists |
| `trustedProfileAnalyzer.storage.type` | `filesystem` | PoC PVC storage |
| `trustedProfileAnalyzer.importers.*.enabled` | CVE/OSV on; CSAF/RH SBOM off | Footprint control |
| `deployer.domain` | `""` | Injected by root-app |

## Local validation

```bash
helm lint charts/components/rhtpa
helm template rhtpa charts/components/rhtpa \
  --set deployer.domain=apps.cluster.example.com

./scripts/helm-validate.sh
```

## Enable from root-app

```bash
helm template lightwell charts/root-app \
  --set components.rhtpa.enabled=true \
  --set deployer.domain=apps.cluster.example.com
```

Keep `components.rhtpa.enabled: false` in committed root values until SSO + cluster capacity are ready.

## Related

- Issue [#5](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/5) — chart scaffold
- RHDA shift-left docs: [#26](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/26) → [docs/rhda-rhtpa-shift-left.md](../../../docs/rhda-rhtpa-shift-left.md)
- Module 4 SBOM lab: [#17](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/17)
- [charts/root-app/README.md](../../root-app/README.md)
