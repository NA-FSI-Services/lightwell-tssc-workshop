# charts/ — production GitOps content

This directory is the **RHDP sync target** for the Lightwell workshop (AgnosticV `gitops_path`: `charts/root-app`).

## Status

Scaffolding in progress. Until `root-app` and components land (Phase 1 issues), use [`examples/helm/`](../examples/helm/) as the structural reference only.

## Intended layout

```
charts/
├── README.md                 # This file
├── root-app/                 # App-of-Apps (ArgoCD Applications)
│   ├── Chart.yaml
│   ├── values.yaml
│   └── templates/
└── components/
    ├── rhdh/
    ├── rhtas/
    ├── rhtpa/
    ├── rhacs/
    ├── lightwell-repo/
    ├── spring-boot-lw-poc/
    ├── showroom/             # or via root-app values
    └── parasol-app/          # optional
```

## Rules

- Prefer patterns from `examples/helm/` (App of Apps + child charts + sync waves).
- Optional ansible-runner Jobs follow `examples/ansible/` and live under a component chart when required.
- Full conventions: [docs/repository-conventions.md](../docs/repository-conventions.md).
