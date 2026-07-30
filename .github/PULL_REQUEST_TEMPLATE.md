## Summary

<!-- What changed and why it advances the Lightwell RHDP workshop. -->

-

## Tracking

- Issue: <!-- e.g. Fixes #N or Refs #N -->
- Phase: <!-- phase-1 | phase-2 | phase-3 | phase-4 | phase-5 -->
- Project: [Lightwell TSSC Workshop](https://github.com/orgs/NA-FSI-Services/projects/1)

## Change type

<!-- Check all that apply -->

- [ ] Helm / GitOps chart (`charts/root-app` or `charts/components/*`)
- [ ] Ansible runner Job (hybrid component; justified why Helm is insufficient)
- [ ] Showroom / AsciiDoc lab (`docs/modules/`)
- [ ] AgnosticV / RHDP infra docs or drafts
- [ ] Documentation / conventions / agent guidance
- [ ] Template reference only (`examples/`) — not production sync path

## Workshop / LWN alignment

- [ ] Supports ordering, ArgoCD sync, or teaching the Lightwell Network narrative on RHDP
- [ ] Uses **Validated** / **Remediated** / OSV terminology (no invented channel names)
- [ ] Remediated version examples use `.rhlw-0000X` when applicable
- [ ] Production content targets `charts/` (not long-term sync of `examples/`)
- [ ] No secrets, registry tokens, customer PII, or engagement-specific details

## Validation

- [ ] `helm template` / `helm lint` succeeds for touched charts (if applicable)
- [ ] Sync waves / dependency order documented or unchanged intentionally
- [ ] Showroom module renders / steps are copy-pasteable (if lab content)
- [ ] RHDP labels considered (`demo.redhat.com/application`, `demo.redhat.com/userinfo`) when adding user-facing resources
- [ ] Linked issue acceptance criteria addressed or explicitly deferred

## Test plan

<!-- Concrete steps a reviewer can run. Prefer RHDP Field Content / agd-v2 CNV order when charts change. -->

1.
2.

## Notes for reviewers

<!-- Reuse sources (RHADS, TSF, RHACS, PoV Spring Boot), follow-ups, or risks. -->

-
