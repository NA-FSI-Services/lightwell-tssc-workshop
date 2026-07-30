# charts/ — production GitOps content

This directory is the **RHDP sync target** for the Lightwell workshop (AgnosticV `gitops_path`: `charts/root-app`).

## Status

`charts/root-app` App-of-Apps is scaffolded. Child component charts under `charts/components/` land in Phase 1 issues (#3–#8, #24) and Showroom wiring (#19). Components stay `enabled: false` in root-app values until their charts exist.

## Layout

```
charts/
├── README.md                 # This file
├── root-app/                 # App-of-Apps (ArgoCD Applications)
│   ├── Chart.yaml
│   ├── values.yaml
│   ├── README.md             # Sync waves + local helm validation
│   └── templates/
└── components/               # Child charts (to be added)
    ├── rhdh/
    ├── rhtas/
    ├── rhtpa/
    ├── rhacs/
    ├── lightwell-repo/
    ├── spring-boot-lw-poc/
    ├── showroom/
    └── parasol-app/          # optional
```

## Sync waves (root-app)

| Wave | Components |
|------|------------|
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
