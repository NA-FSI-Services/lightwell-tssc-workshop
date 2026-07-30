# charts/components/spring-boot-lw-poc — primary Java sample

Primary learner workload: **Spring Boot / Java 17 / Maven** greeting API with OpenAPI, demonstrating Lightwell Network **Validated** and **Remediated** (`.rhlw-*`) consumption.

Parasol (`#8`) remains optional and secondary.

## Layout

```
spring-boot-lw-poc/
├── Chart.yaml / values.yaml / templates/   # GitOps deploy (Deployment, Route, docs)
└── app/                                    # Maven project sources
    ├── pom.xml                             # dual-stream version properties + profiles
    ├── settings.xml                        # lightwell-validated / lightwell-remediated
    ├── Dockerfile
    └── src/main/java/.../GreetingController.java
```

## Learner commands

```bash
cd charts/components/spring-boot-lw-poc/app
export LIGHTWELL_NEXUS_URL=https://nexus-lightwell-repo.apps.<domain>
mvn -s settings.xml -Plightwell-validated clean verify
mvn -s settings.xml -Plightwell-validated dependency:tree
mvn -s settings.xml -Plightwell-validated spring-boot:run

# Remediated exact-version pin (needs LWN / seeded Nexus for .rhlw-* artifact)
mvn -s settings.xml -Plightwell-remediated,lightwell-remediated-pins clean verify

# SBOM for RHTPA
mvn -s settings.xml -Plightwell-validated -DskipTests package
syft packages dir:. -o cyclonedx-json > sbom.cdx.json
```

Endpoints (after Route is up): `/api/greeting`, `/api/healthz`, `/swagger-ui.html`.

## Image / deploy

1. Build and push from `app/Dockerfile` into the cluster registry (or Quay).
2. Set `image.repository` / `image.tag` in values (defaults assume in-cluster registry path).
3. Enable from root-app: `components.springBootLwPoc.enabled=true`.

## Sync waves

| Wave | Resources |
|------|-----------|
| `0` | Namespace |
| `1` | Lab docs ConfigMap |
| `2` | Deployment + Service |
| `3` | Route |
| `4` | RHDP userinfo |

Root App-of-Apps places this chart at sync wave **`40`**.

## Related

- Issue [#24](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/24)
- Artifact manager: [#7](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/7)
- Optional Parasol: [#8](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/8)
