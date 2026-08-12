# [Project Name]

<!-- Replace with your project name and brief description. -->

## Getting Started

1. Clone this template and scaffold your lab pattern:

```bash
git clone https://github.com/rhpds/rhdp-publishing-house-template my-lab
cd my-lab
python scaffold.py
```

2. Install the RHDP Publishing House skills plugin in Claude Code or Cursor
3. Run `/rhdp-publishing-house` in this directory to start intake
4. Follow the orchestrator's guidance

## Lab Patterns

The scaffold script (`scaffold.py`) configures this template for one of three lab patterns:

| Pattern | Infrastructure | Showroom | Created Directories | site.yml |
|---------|---------------|----------|---------------------|----------|
| **AgD v2 Open** | AgnosticD v2 | Classic (no solve/validate) | `content/` only | `rhdp_showroom_theme` (default) |
| **AgD v2 Guided** | AgnosticD v2 | Guided (solve/validate buttons) | `runtime-automation/`, `content/` | `nookbag-bundle` (overwritten) |
| **ZT Guided** | Project Zero | Guided (solve/validate buttons) | `config/`, `setup-automation/`, `runtime-automation/`, `content/` | `nookbag-bundle` (overwritten) |

After scaffolding, edit `ui-config.yml` to configure tabs for your infrastructure target (terminals, OCP console, external URLs).
See the [showroom-template](https://github.com/rhpds/showroom-template) branches for example tab configurations.

Run `python scaffold.py --help` for non-interactive usage.

## Structure

- `scaffold.py` — Lab pattern scaffolding script (run once after cloning)
- `_scaffolds/` — Pattern-specific files (removed after scaffolding)
- `content/` — Showroom AsciiDoc content (Antora modules)
- `qa-automation/` — Health check and e2e test playbooks
- `podman-compose.yaml` — Local dev preview (`podman compose up`, then http://localhost:8080)
- `publishing-house/` — Project state (manifest), specs, reviews, decisions
- `site.yml` — Antora playbook (open patterns use `rhdp_showroom_theme`; guided patterns use `nookbag-bundle`)
- `ui-config.yml` — Showroom UI layout config (set by scaffold, customize tabs afterward)

### After Scaffolding (pattern-specific)

- `runtime-automation/` — Per-module solve/validate playbooks (Guided patterns)
- `setup-automation/` — Environment setup playbook (ZT Guided only)
- `config/` — Project Zero instance, network, and firewall definitions (ZT Guided only)
