# charts/components/lightwell-repo — Lightwell Network artifact manager

Enterprise **artifact manager** pattern (Sonatype Nexus) presenting Lightwell Network tiers used in field PoV delivery:

| Tier | Purpose | Canonical remote |
|------|---------|------------------|
| **Validated** (Java) | Upstream-parity rebuilds | `https://packages.redhat.com/lightwell/java/validated` |
| **Remediated** (Java) | Exact-version `.rhlw-0000X` backports | `https://packages.redhat.com/lightwell/java/remediated` |
| **OSV (Java)** | Fixed-vuln records for remediated | `https://packages.redhat.com/lightwell/osv/java/remediated` |
| **Validated** (Python / PyPI) | Upstream-parity rebuilds for `pip` | `https://packages.redhat.com/lightwell/python/validated` |
| **Remediated** (Python / PyPI) | Exact-version `.rhlw-0000X` backports | `https://packages.redhat.com/lightwell/python/remediated` |

pip simple-index paths append `/simple` (e.g. `…/python/validated/simple`).

Do **not** invent alternate channel names such as `upstream-untrusted` / `lightwell-network-secured`.

## Modes (live proxy vs seeded mirror)

| `lightwellRepo.mode` | When to use | Behavior |
|----------------------|-------------|----------|
| **`seeded`** (default) | RHDP / offline / deterministic labs | Nexus **hosted** repos; Job `lightwell-repo-seed` uploads curated Maven stubs, OSV JSON, CycloneDX SBOMs, and PyPI wheels |
| **`proxy`** | Live LWN membership available | Nexus **proxy** repos to canonical `packages.redhat.com` URLs using Secret `lightwell-network-credentials` (`LW_USERNAME` / `LW_PASSWORD`) |

Set mode in values (or root-app overlay). Never commit real `LW_*` values.

### PyPI Remediated (required)

`channels.pypiRemediated.enabled` **must stay `true`** for this Java+Python catalog:

- **seeded + enabled** — creates hosted PyPI Remediated and uploads a workshop `.rhlw-*` marker wheel (does **not** call live LWN)
- **proxy + enabled** — creates PyPI proxy to `…/python/remediated`

Do **not** set `enabled: false` for catalog claims. The seeded marker keeps Module 8 deterministic without live Remediated PyPI membership.

### Seeded content (default)

Two Maven seed kinds on purpose (Module 2 teaches both):

| Kind | Coordinates | JAR | Lab use |
|------|-------------|-----|---------|
| **Resolution stub** | `spring-core:5.3.18` (+ `.rhlw-00003`) | Manifest-only workshop stub | `mvn dependency:get` — prove Nexus hosts Lightwell-shaped GAVs |
| **Compile-capable** | `commons-lang3:3.14.0` (+ `.rhlw-00001`) | Real Apache Commons Lang 3.14.0 (ASL 2.0), fetched from Maven Central at seed time | `mvn clean verify` — enterprise manager feeds a real PoC build |

| Coordinate | Tier | Notes |
|------------|------|-------|
| `org.springframework:spring-core:5.3.18` | Validated | Resolution stub; OSV demo base version |
| `org.springframework:spring-core:5.3.18.rhlw-00003` | Remediated | Resolution stub; exact-version suffix |
| `org.apache.commons:commons-lang3:3.14.0` | Validated | Compile-capable; matches `spring-boot-lw-poc` validated pin |
| `org.apache.commons:commons-lang3:3.14.0.rhlw-00001` | Remediated | Same binary under `.rhlw-*`; matches `lightwell-remediated-pins` |

**OSV** (raw repo `lightwell-osv-java-remediated`):

```text
osv/java/remediated/LW-DEMO-0001.json
```

`affected[].ranges[].events[].fixed` → `5.3.18.rhlw-00003`.

**CycloneDX** (same raw repo):

```text
sbom/java/validated/org.springframework/spring-core/5.3.18.cdx.json
sbom/java/remediated/org.springframework/spring-core/5.3.18.rhlw-00003.cdx.json
```

**PyPI** (Modules 7–9):

| Package | Tier | Notes |
|---------|------|-------|
| `httpx==0.27.2` | Validated | Real wheel fetched from PyPI at seed time; usable by FastAPI sample |
| `lw-workshop-pypi==1.0.0+rhlw.00001` | Remediated (required) | Workshop marker proving `.rhlw-0000X` on the Remediated index |

Override the Commons Lang download URL with env `COMMONS_LANG3_JAR_URL` on the seed Job if the cluster cannot reach Maven Central. Override the httpx wheel with `pypiSeed.wheelUrl` / `PYPI_SEED_WHEEL_URL` if the cluster cannot reach `files.pythonhosted.org`.

## Sync waves (inside this chart)

| Wave | Resources |
|------|-----------|
| `0` | Namespace |
| `1` | Credentials / Nexus admin placeholders, channel / Maven / pip / OSV / seed ConfigMaps |
| `2` | Nexus Deployment + PVC + Service |
| `3` | OpenShift Route |
| `4` | Seed RBAC + Job `lightwell-repo-seed` + oc-mirror PVC/SA/tooling (no Hummingbird pull) |
| `5` | RHDP userinfo |

Root App-of-Apps places this chart at sync wave **`20`**.

## Dest registry (V2-10)

Nexus **hosted Docker** repo `hummingbird-mirror` is the oc-mirror destination. It is created **empty**. Provision does **not** pull or push `HUMMINGBIRD_JAVA_RUNTIME` (V2-1 pin is userinfo only). Learners run oc-mirror in V2-11.

| Item | Value |
|------|--------|
| Docker connector | container/Service port `5000` |
| Route | `registry-lightwell-repo.<domain>` (TLS edge) |
| oc-mirror dest | `docker://registry-lightwell-repo.<domain>` |
| Plugin image | `registry.redhat.io/openshift4/oc-mirror-plugin-rhel9:v4.20` (bake into Showroom is V2-20) |
| Workspace | PVC `oc-mirror-workspace` |
| Push auth | Secret `nexus-docker-push` (seed Job; admin → dest host) |
| Tooling | ConfigMap `oc-mirror-tooling` (`README`, learner `job.yaml`, worked example) |

Source pin (do not invent):

```
registry.access.redhat.com/hi/openjdk:21-runtime@sha256:e7c41dc2cba28c49d551c491419e00b75c5aef6c13326cc08765d30e882630ba
```

## Incomplete ImageSet (V2-11)

ConfigMap `imageset-configuration` is seeded with `REPLACE_ME_HUMMINGBIRD_PULLSPEC`. No provision Job runs oc-mirror.

| Item | Value |
|------|--------|
| Scored file | ConfigMap `imageset-configuration` key `imageset-config.yaml` |
| Worked example | `oc-mirror-tooling` key `example-imageset.yaml` (`ubi9/ubi-minimal` — not paste-identical) |
| Learner edit | Replace `REPLACE_ME_HUMMINGBIRD_PULLSPEC` with the V2-1 digest pin |
| Run from Showroom | `oc get cm oc-mirror-tooling -o jsonpath='{.data.job\.yaml}' \| oc create -f -` |
| Signatures | Job does **not** pass `--remove-signatures` (oc-mirror v2 default includes them) |

```bash
oc -n lightwell-repo edit configmap imageset-configuration
# set additionalImages[0].name to hummingbird_source_pullspec from demo-userinfo-lightwell-repo
oc -n lightwell-repo get configmap oc-mirror-tooling -o jsonpath='{.data.job\.yaml}' | oc create -f -
```

## Credentials

### Lightwell Network (proxy mode)

```bash
oc -n lightwell-repo create secret generic lightwell-network-credentials \
  --from-literal=LW_USERNAME='<registry-sa|name>' \
  --from-literal=LW_PASSWORD='<token>' \
  --dry-run=client -o yaml | oc apply -f -
```

### Nexus admin (optional)

The seed Job captures `/nexus-data/admin.password` via `oc exec` when Secret `nexus-admin-credentials` password is empty. To set explicitly:

```bash
PASSWORD=$(oc -n lightwell-repo exec deploy/nexus -- cat /nexus-data/admin.password)
oc -n lightwell-repo create secret generic nexus-admin-credentials \
  --from-literal=username=admin --from-literal=password="$PASSWORD" \
  --dry-run=client -o yaml | oc apply -f -
```

**Never commit** service-account tokens or passwords.

## Maven learner UX

ConfigMap `lightwell-maven-settings` provides `settings.xml` with profiles:

- `lightwell-validated`
- `lightwell-remediated`

```bash
oc -n lightwell-repo extract configmap/lightwell-maven-settings --keys=settings.xml --to=.
mvn -s settings.xml -Plightwell-validated clean verify
# After seed Job succeeds:
mvn -s settings.xml dependency:get \
  -Dartifact=org.springframework:spring-core:5.3.18.rhlw-00003 \
  -Plightwell-remediated
```

## Python / pip learner UX

ConfigMap `lightwell-pip-settings` provides `pip.conf` (Validated) and `pip-remediated.conf`.

Learner-facing Nexus index URLs (Showroom / Module 7 attrs):

| Tier | Nexus simple index |
|------|--------------------|
| Validated | `https://nexus-lightwell-repo.<domain>/repository/lightwell-python-validated/simple` |
| Remediated | `https://nexus-lightwell-repo.<domain>/repository/lightwell-python-remediated/simple` |

Also published on ConfigMap `demo-userinfo-lightwell-repo` keys `pypi_index_validated` / `pypi_index_remediated`.

```bash
oc -n lightwell-repo extract configmap/lightwell-pip-settings --keys=pip.conf --to=.
PIP_CONFIG_FILE=$PWD/pip.conf pip install httpx==0.27.2
# Remediated marker (Module 8 — channels.pypiRemediated.enabled=true required):
oc -n lightwell-repo extract configmap/lightwell-pip-settings --keys=pip-remediated.conf --to=.
PIP_CONFIG_FILE=$PWD/pip-remediated.conf pip install lw-workshop-pypi==1.0.0+rhlw.00001
```

Canonical remotes (document even when mirroring):

```text
https://packages.redhat.com/lightwell/python/validated
https://packages.redhat.com/lightwell/python/validated/simple
https://packages.redhat.com/lightwell/python/remediated
https://packages.redhat.com/lightwell/python/remediated/simple
```

## Reuse / references

- [Configure Artifactory for LWN Java](https://docs.redhat.com/en/documentation/red_hat_lightwell_network/current/configure-configure_artifactory_to_use_rhln_repository) (same remotes / `.rhlw-*` naming; this chart uses Nexus as the workshop stand-in)
- [Configure Python build tool for LWN](https://docs.redhat.com/en/documentation/red_hat_lightwell_network/current/configure-configure_python_build_tool)
- [DEVELOPMENT-PLAN.md](../../../DEVELOPMENT-PLAN.md) — Lab model
- [console.redhat.com/lightwell](https://console.redhat.com/lightwell)

## Local validation

```bash
helm lint charts/components/lightwell-repo
helm template lightwell-repo charts/components/lightwell-repo \
  --set deployer.domain=apps.cluster.example.com

./scripts/helm-validate.sh
```

## Enable from root-app

```bash
helm template lightwell charts/root-app \
  --set components.lightwellRepo.enabled=true \
  --set deployer.domain=apps.cluster.example.com
```

Keep `components.lightwellRepo.enabled: false` until ready to sync.

## Related

- Issue [#7](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/7) — chart scaffold
- Issue [#11](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/11) — seed / proxy content
- Issue [#145](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/145) — PyPI Validated + Remediated (always on)
- [V2-10](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/3) — dest Docker repo + oc-mirror tooling (no pre-mirror)
- [V2-11](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/4) — incomplete ImageSet + learner-run Job
- Epic [#144](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/144) — Python path Modules 7–9 (Java + Python catalog)
- OSV toolkit (pin parse + source diff): [`tools/osv-eval/`](../../../tools/osv-eval/) / [#25](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/25)
