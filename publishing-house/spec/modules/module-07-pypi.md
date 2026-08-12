# Module 07 — PyPI Validated + FastAPI (Python Track Kickoff)

### Brief Overview

This module opens the Python track, mirroring the Module 2–3 Java pattern for the PyPI ecosystem. It establishes the FastAPI sample application (`lw-fastapi`) as the Python equivalent of the Spring Boot PoC and confirms that Python artifact resolution works through the Lightwell Validated PyPI channel proxied via Nexus. Learners extract a `pip.conf` from a cluster ConfigMap, seed two Gitea repositories (app and gitops), prove that `httpx` resolves from the validated Nexus index, then delete the seeded app repo and re-scaffold it via the `lightwell-python-service` RHDH Software Template — completing the Python golden path establishment.

### Audience and Time

- **Personas:** Python developers, DevSecOps engineers, platform engineers
- **Prerequisites for this module:** Module 6 complete (or Module 3 if attending Python-only track); oc CLI available; pip and Python 3 installed in Showroom terminal; RHDH running with `lightwell-python-service` template loaded; Gitea accessible
- **Estimated duration:** 30 min

### Learning Objectives

- Configure pip.conf to resolve Python packages from the enterprise-proxied Lightwell Validated PyPI repository
- Scaffold a Python application repository from a Red Hat Developer Hub Software Template using the lightwell-python-service golden path

### Lab Structure

| Section | Title | Duration |
|---------|-------|----------|
| 1 | Enterprise PyPI patterns overview (mirrors Module 2 Java patterns) | 3 min |
| 2 | Exercise 1: Discover URLs and extract pip.conf from ConfigMap | 5 min |
| 3 | Exercise 2: Create and seed Python Gitea repos | 5 min |
| 4 | Exercise 3: Validated install — prove httpx resolves from Lightwell Nexus | 5 min |
| 5 | Exercise 4: Delete seeded app repo via Gitea API | 3 min |
| 6 | Exercise 5: Scaffold via lightwell-python-service template in RHDH | 7 min |
| 7 | Exercise 6: Re-prove Validated on the scaffolded repo | 2 min |

### Detailed Steps

1. Read the enterprise PyPI patterns section: the three patterns (Direct, Proxied, Seeded) apply to PyPI exactly as they do to Maven. The Proxied pattern uses Nexus as a PyPI simple index proxy.
2. **Exercise 1 — Discover URLs:** Run `oc -n lightwell-repo extract configmap/lightwell-pip-settings --to=-` (or `oc get configmap lightwell-pip-settings -o yaml`) to retrieve the `pip.conf` content including the Nexus PyPI index URL.
3. Save the extracted `pip.conf` to `~/.config/pip/pip.conf` (or a local path for use with `PIP_CONFIG_FILE`).
4. Inspect `pip.conf` — confirm `index-url` points to the Lightwell Validated Nexus PyPI simple index endpoint.
5. **Exercise 2 — Seed Gitea repos:** Use the Gitea API or git push to create two repositories in the learner's Gitea account: `lw-fastapi` (application repo) and `lw-fastapi-gitops` (GitOps Helm repo). The content for seeding comes from the pre-staged fixtures in the Showroom home directory.
6. Clone the seeded `lw-fastapi` repo and inspect `requirements.txt` to see the current (non-remediated) dependency list.
7. **Exercise 3 — Validated install:** Set `PIP_CONFIG_FILE=<path-to-pip.conf>` and run `python3 -m pip install -r requirements.txt` inside a virtual environment.
8. Confirm `httpx` (a FastAPI dependency) resolves from the Lightwell Validated Nexus PyPI index, not from pypi.org. Check the install output for the Nexus URL.
9. **Exercise 4 — Delete seeded repo:** Run the Gitea API DELETE: `curl -sk -X DELETE -H "Authorization: basic <b64creds>" https://<gitea-url>/api/v1/repos/<username>/lw-fastapi`. Confirm 204 response.
10. **Exercise 5 — Scaffold via RHDH:** Open the RHDH console. Navigate to **Create → Software Templates** and locate `lightwell-python-service`.
11. Fill the template form: application name (`lw-fastapi`), Gitea organization, owner username. Submit.
12. Wait for RHDH to scaffold the repo, confirm the task completes successfully in the RHDH task pane.
13. **Exercise 6 — Re-prove Validated:** Clone the freshly scaffolded `lw-fastapi` repo. Confirm `pip.conf` (or a `.pip.conf` in the project root) is included in the scaffolded layout.
14. Run `PIP_CONFIG_FILE=... python3 -m pip install -r requirements.txt` against the scaffolded `requirements.txt`.
15. **Verification:** Install succeeds; `httpx` and other FastAPI dependencies resolve from the Lightwell Validated Nexus PyPI index.

### Key Takeaways

- The PyPI proxied consumption pattern is structurally identical to Maven: `pip.conf` plays the same role as `settings.xml`, and the Nexus PyPI simple index proxy plays the same role as the Maven proxy repository.
- Extracting `pip.conf` from a ConfigMap is the discovery mechanism — learners don't need to know the Nexus URL in advance.
- The delete-and-scaffold pattern (mirroring Module 3) reinforces that the RHDH golden path, not manual repo creation, is the correct enterprise starting point.
- The `lightwell-python-service` Software Template encodes the same enterprise standards as `lightwell-java-service` — correct Nexus index, CI/CD wiring, and project layout — but for the Python/FastAPI ecosystem.
- `httpx` resolving from Lightwell Nexus (not pypi.org) is the observable proof that pip is correctly routed through the enterprise proxy.

### Infrastructure Notes

- Nexus must have a PyPI simple index proxy repository configured for Lightwell Validated PyPI, backed by the relevant `packages.redhat.com/lightwell/pypi/` endpoint.
- `lightwell-pip-settings` ConfigMap must be pre-created in the `lightwell-repo` namespace with the correct `pip.conf` content.
- Gitea must accept API requests to create and delete repos from the learner's user.
- RHDH must have the `lightwell-python-service` Software Template pre-loaded with correct Gitea integration.
- Fixture tarballs for the seeded `lw-fastapi` and `lw-fastapi-gitops` repos must be pre-staged in the Showroom home directory.
- Python 3 and pip must be available in the Showroom base image; virtualenv or venv must also be available.
