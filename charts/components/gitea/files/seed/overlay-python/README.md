# fastapi-lw-poc (student lab repository)

Learner-owned **FastAPI / Python** application repository for the Lightwell TSSC
workshop (hosted on in-cluster **Gitea**).

Use this repository for Modules 7–9 (PyPI Validated → remediated-when-available →
pipeline / GitOps). Discover your remote from ConfigMap `demo-userinfo-gitea`
(`student_python_repo_url`).

## Layout

| Path | Purpose |
|------|---------|
| `requirements.txt` / `main.py` / `Dockerfile` | App sources at repository root |
| `pip.conf` / `pip-remediated.conf` | Lightwell Validated / Remediated PyPI indexes |
| `.tekton/` | Stub pipeline for Module 9 (Tasks fleshed out in workshop #149) |
| `README.md` | This file |

## Clone path

```bash
# requirements.txt must be at repo root (never a monorepo subdirectory)
cd /tmp/fastapi-lw-poc
```

Never clone the workshop GitHub monorepo for lab work.
