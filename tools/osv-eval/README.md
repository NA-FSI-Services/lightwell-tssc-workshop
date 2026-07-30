# OSV evaluation toolkit (Module 3)

Deterministic helpers for the Lightwell **OSV → `.rhlw-*` pin → source diff → rebuild** loop.  
No customer systems required. Sample OSV matches the seeded Nexus path from [`charts/components/lightwell-repo`](../../charts/components/lightwell-repo/).

## Layout

```text
tools/osv-eval/
├── samples/LW-DEMO-0001.json     # Maven ecosystem fixed: 5.3.18.rhlw-00003
├── fixtures/{upstream,remediated}/  # Offline source trees for diff -r
├── scripts/
│   ├── osv-pin.sh                # Parse OSV → GAV + fixed .rhlw-* pin
│   ├── diff-sources.sh           # Fixture or fetch *-sources.jar + diff -r
│   └── poll-pulp-manifest.sh     # Instructor: PULP_MANIFEST watch
└── playbooks/poll-osv-manifest.yml
```

## Sample OSV (acceptance)

```bash
jq '.affected[0].ranges[0].events' tools/osv-eval/samples/LW-DEMO-0001.json
# fixed → 5.3.18.rhlw-00003

./tools/osv-eval/scripts/osv-pin.sh tools/osv-eval/samples/LW-DEMO-0001.json
```

Canonical path shape (seeded or live):

```text
osv/java/remediated/LW-DEMO-0001.json
https://packages.redhat.com/lightwell/osv/java/remediated
```

Also available in-cluster via ConfigMap `lightwell-sample-osv` / Nexus raw repo after [#11](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/11).

## Source diff (Showroom-friendly)

### Offline / RHDP default (fixtures)

```bash
chmod +x tools/osv-eval/scripts/*.sh
./tools/osv-eval/scripts/diff-sources.sh --fixture
```

Shows `diff -ruN` between stub upstream vs remediated trees (length check added in remediated).

### Live / instructor (fetch `-sources.jar`)

```bash
export LIGHTWELL_NEXUS_URL='https://nexus-lightwell-repo.apps.<domain>'
# Optional for packages.redhat.com:
# export LW_USERNAME=... LW_PASSWORD=...

./tools/osv-eval/scripts/diff-sources.sh --fetch \
  --osv tools/osv-eval/samples/LW-DEMO-0001.json
```

Manual equivalent:

```bash
# After downloads into /tmp/lw-osv/{upstream,remediated}-sources.jar
mkdir -p /tmp/lw-osv/{u,r}
cd /tmp/lw-osv/u && jar xf ../spring-core-5.3.18-sources.jar
cd /tmp/lw-osv/r && jar xf ../spring-core-5.3.18.rhlw-00003-sources.jar
diff -ruN /tmp/lw-osv/u /tmp/lw-osv/r
```

Then pin and rebuild (learner app / scaffold):

```bash
# pom.xml properties → commons-lang3 or spring-core .rhlw-* from OSV fixed event
mvn -s settings.xml -Plightwell-remediated,lightwell-remediated-pins clean verify
```

## Instructor appendix — PULP_MANIFEST polling

Optional automation narrative (issue #25 / plan note). **Generic ticketing hook only.**

```bash
# Single shot (requires network + optional LW_*)
./tools/osv-eval/scripts/poll-pulp-manifest.sh

# Or Ansible-style:
ansible-playbook tools/osv-eval/playbooks/poll-osv-manifest.yml
```

On checksum change the tools print: open a ticket / trigger a rebuild pipeline — map that to your org’s tooling outside this repo.

Showroom appendix: [`docs/modules/ROOT/pages/appendix-osv-manifest-polling.adoc`](../../docs/modules/ROOT/pages/appendix-osv-manifest-polling.adoc) ([#27](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/27)).

## Related

- Module 3 lab authoring: [#16](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/16)
- Seeded OSV in Nexus: [#11](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/11)
- [DEVELOPMENT-PLAN.md](../../DEVELOPMENT-PLAN.md) — Lab model / OSV
