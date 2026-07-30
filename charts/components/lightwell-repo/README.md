# charts/components/lightwell-repo — Lightwell Network artifact manager

Enterprise **artifact manager** pattern (Sonatype Nexus) presenting Lightwell Network tiers used in field PoV delivery:

| Tier | Purpose | Canonical remote |
|------|---------|------------------|
| **Validated** | Upstream-parity rebuilds | `https://packages.redhat.com/lightwell/java/validated` |
| **Remediated** | Exact-version `.rhlw-0000X` backports | `https://packages.redhat.com/lightwell/java/remediated` |
| **OSV (Java)** | Fixed-vuln records for remediated | `https://packages.redhat.com/lightwell/osv/java/remediated` |

Do **not** invent alternate channel names such as `upstream-untrusted` / `lightwell-network-secured`.

## Modes (live proxy vs seeded mirror)

| `lightwellRepo.mode` | When to use | Behavior |
|----------------------|-------------|----------|
| **`seeded`** (default) | RHDP / offline / deterministic labs | Nexus **hosted** repos; Job `lightwell-repo-seed` uploads curated Maven stubs, OSV JSON, and CycloneDX SBOMs |
| **`proxy`** | Live LWN membership available | Nexus **proxy** repos to canonical `packages.redhat.com` URLs using Secret `lightwell-network-credentials` (`LW_USERNAME` / `LW_PASSWORD`) |

Set mode in values (or root-app overlay). Never commit real `LW_*` values.

### Seeded content (default)

| Coordinate | Tier | Notes |
|------------|------|-------|
| `org.springframework:spring-core:5.3.18` | Validated | OSV demo base version |
| `org.springframework:spring-core:5.3.18.rhlw-00003` | Remediated | Exact-version suffix (issue #11 example style) |
| `org.apache.commons:commons-lang3:3.14.0` | Validated | Matches `spring-boot-lw-poc` validated profile |
| `org.apache.commons:commons-lang3:3.14.0.rhlw-00001` | Remediated | Matches `lightwell-remediated-pins` profile |

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

Stub JARs are workshop placeholders (manifest-only) so Maven resolution succeeds without redistributing upstream binaries.

## Sync waves (inside this chart)

| Wave | Resources |
|------|-----------|
| `0` | Namespace |
| `1` | Credentials / Nexus admin placeholders, channel / Maven / OSV / seed ConfigMaps |
| `2` | Nexus Deployment + PVC + Service |
| `3` | OpenShift Route |
| `4` | Seed RBAC + Job `lightwell-repo-seed` |
| `5` | RHDP userinfo |

Root App-of-Apps places this chart at sync wave **`20`**.

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

## Reuse / references

- [Configure Artifactory for LWN Java](https://docs.redhat.com/en/documentation/red_hat_lightwell_network/current/configure-configure_artifactory_to_use_rhln_repository) (same remotes / `.rhlw-*` naming; this chart uses Nexus as the workshop stand-in)
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
- OSV toolkit (pin parse + source diff): [`tools/osv-eval/`](../../../tools/osv-eval/) / [#25](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/25)
