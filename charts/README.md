# charts/ — production GitOps content

This directory is the **RHDP sync target** for the Lightwell workshop (AgnosticV `gitops_path`: `charts/root-app`).

## Status

`charts/root-app` App-of-Apps is scaffolded. Phase 1 component charts (#3–#8, #24) and Showroom (#19) are available. Keep non-Showroom components `enabled: false` in root-app values until ready to sync on a sized cluster; Showroom is enabled and builds Modules 1–5 from `site.yml`.

## Layout

```
charts/
├── README.md                 # This file
├── root-app/                 # App-of-Apps (ArgoCD Applications)
│   ├── Chart.yaml
│   ├── values.yaml
│   ├── README.md             # Sync waves + local helm validation
│   └── templates/
└── components/
    ├── keycloak/             # Workshop IdP for RHTPA (sso.<domain>/realms/tpa)
    ├── rhdh/                 # Developer Hub + lightwell-java-service placeholder (#3)
    ├── rhtas/                # Trusted Artifact Signer (Fulcio/Rekor/TUF) (#4)
    ├── rhtpa/                # Trusted Profile Analyzer (SBOM/VEX) (#5)
    ├── rhacs/                # Advanced Cluster Security + roxctl hooks (#6)
    ├── lightwell-repo/       # Nexus LWN validated / remediated / OSV (#7)
    ├── spring-boot-lw-poc/   # Primary Spring Boot / LWN Maven PoC (#24)
    ├── showroom/             # RHDP Showroom UI + terminal (Modules 1–5) (#19)
    └── parasol-app/          # Optional multi-tier Parasol scaffold (#8)
```


## Sync waves (root-app)

| Wave | Components |
|------|------------|
| 5 | keycloak |
| 10 | rhtas, rhtpa, rhacs |
| 20 | lightwell-repo |
| 30 | rhdh |
| 40 | spring-boot-lw-poc, parasol-app |
| 50 | showroom |

Details: [root-app/README.md](root-app/README.md).

## Rules

- Prefer patterns from `examples/helm/` (App of Apps + child charts + sync waves).
- Optional ansible-runner Jobs follow `examples/ansible/` and live under a component chart when required.
- Full conventions: [docs/repository-conventions.md](../docs/repository-conventions.md).
