# Modules 7–9 — using this scaffold

This tree is the **canonical learner FastAPI application** after the RHDH
Software Template `lightwell-python-service` publishes to Gitea `fastapi-lw-poc`
(Module 7+ scaffold step — mirrors Module 3 for Java).

| Module | Focus | Assets here |
|--------|--------|-------------|
| 7 | Scaffold + PyPI Validated | `requirements.txt`, `pip.conf` |
| 8 | Remediated PyPI (when gated on) | `pip-remediated.conf` |
| 9 | Pipeline / signing / GitOps | `.tekton/` (stub until #149) |

Clone URL: ConfigMap `demo-userinfo-gitea` → `student_python_repo_url` (not GitHub).

Flow: Module 7 learner seed (`learner-seed-python-from-templates.sh`) first, then
delete `lw-<username>/fastapi-lw-poc` and re-publish with this template (Java
Module 2 → Module 3 pattern).
