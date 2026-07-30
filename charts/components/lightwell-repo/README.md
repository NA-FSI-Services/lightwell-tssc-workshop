# charts/components/lightwell-repo — Lightwell Network artifact manager

Enterprise **artifact manager** pattern (Sonatype Nexus) presenting Lightwell Network tiers used in field PoV delivery:

| Tier | Purpose | Canonical remote |
|------|---------|------------------|
| **Validated** | Upstream-parity rebuilds | `https://packages.redhat.com/lightwell/java/validated` |
| **Remediated** | Exact-version `.rhlw-0000X` backports | `https://packages.redhat.com/lightwell/java/remediated` |
| **OSV (Java)** | Fixed-vuln records for remediated | `https://packages.redhat.com/lightwell/osv/java/remediated` |

Do **not** invent alternate channel names such as `upstream-untrusted` / `lightwell-network-secured`.

## Modes

| `lightwellRepo.mode` | Behavior |
|----------------------|----------|
| `seeded` (default) | Hosted repos + sample OSV JSON for deterministic RHDP labs; curated Java sample set lands in [#11](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/11) |
| `proxy` | Nexus remote/proxy repos to canonical LWN URLs using `LW_USERNAME` / `LW_PASSWORD` |

## Sync waves (inside this chart)

| Wave | Resources |
|------|-----------|
| `0` | Namespace |
| `1` | Credentials placeholder, channels / Maven settings / OSV / bootstrap ConfigMaps |
| `2` | Nexus Deployment + PVC + Service |
| `3` | OpenShift Route |
| `4` | RHDP userinfo |

Root App-of-Apps places this chart at sync wave **`20`**.

## Credentials

Secret `lightwell-network-credentials` is created empty. Inject via RHDP:

```bash
oc -n lightwell-repo create secret generic lightwell-network-credentials \
  --from-literal=LW_USERNAME='<registry-sa|name>' \
  --from-literal=LW_PASSWORD='<token>' \
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
```

Remediated pins use suffixes such as `5.3.18.rhlw-00003` (sample OSV in ConfigMap `lightwell-sample-osv`).

## Bootstrap

ConfigMap `lightwell-repo-bootstrap` includes a `create-repos.sh` sketch for Nexus REST repository creation. Automate with a Job / ansible-runner in Phase 3 (#11) after Nexus is Ready and credentials are injected.

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

- Issue [#7](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/7)
- Seed / proxy content: [#11](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/11)
- OSV toolkit: [#25](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/25)
