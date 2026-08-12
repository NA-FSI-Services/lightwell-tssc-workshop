# Publishing House Project

## On every session start

Read `publishing-house/spec.yaml`. Check the workflow stage by running `/rhdp-publishing-house`.

Do NOT read manifest.yaml — it does not exist. All project data is in `publishing-house/spec.yaml`.

## State
Project state tracked in [publishing-house/spec.yaml](publishing-house/spec.yaml).
Read it first every session.

## Scaffolding
Run `python scaffold.py` after cloning to select a lab pattern (AgD v2 Open,
AgD v2 Guided, or ZT Guided). The script copies pattern-specific stubs into the
project root (including `ui-config.yml` and, for guided patterns, `site.yml` with
the nookbag UI bundle), sets `showroom_type` and `infrastructure` in the spec,
and removes `_scaffolds/`. The orchestrator calls `scaffold.py --pattern <name> --force`
during intake.

## Content
Showroom AsciiDoc content lives in [content/](content/). The Antora component descriptor
is at `content/antora.yml` and modules are in `content/modules/ROOT/pages/`.

## Automation
Pattern-specific automation directories are created by `scaffold.py`:

- `runtime-automation/` — Per-module solve/validate playbooks (Guided patterns)
- `setup-automation/` — Environment setup playbook (ZT Guided only)
- `config/` — Project Zero instance/network/firewall definitions (ZT Guided only)

Common to all patterns:

- `qa-automation/` — Health check and e2e test playbooks

## Architecture

- **project_id**: comes from `catalog-info.yaml` `metadata.name`
- **Central API URL**: comes from `publishing-house/spec.yaml` `system.central`
- **Auth**: Bearer token from `~/.config/publishing-house/auth.json`
- **Stage**: queried from Central API via `/api/v1/projects/{project_id}/orchestrator-state`

## Stage: intake

Use the `/rhdp-publishing-house` skill. It will conduct the spec interview, write the design, and submit to the Central API.

Do NOT change stage manually. Stage transitions are managed by SonataFlow via the Central API.

## Stage: development

Help the author write content. Answer questions about AsciiDoc, module structure, learning objectives, procedures. You are an assistant — do not advance stages or modify spec without explicit instruction.

Run compliance check when asked:
```bash
python publishing-house/tools/ph-check.py
```

## Stage: review or ready

Show the author the current spec or compliance results and wait for instruction.

## Tools

All project tools live in `publishing-house/tools/`:
- `ph-intake.py` — submit intake to Central API (called by orchestrator skill)
- `ph-check.py` — run local compliance checks against spec and content

## File locations
- Project spec: `publishing-house/spec.yaml`
- Design doc: `publishing-house/spec/design.md`
- Module outlines: `publishing-house/spec/modules/`
- Content: `content/modules/ROOT/pages/`
- Navigation: `content/modules/ROOT/nav.adoc`
