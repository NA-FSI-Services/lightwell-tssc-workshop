# V2-23 Spike: Hermeto vs workshop prefetch

**Status:** closed (option 1). Task ships in this change.
**Date:** 2026-08-18
**Issue:** [V2-23](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/15)
**Does not change** `publishing-house/spec.yaml` until you explicitly apply v2.

Track 4.2 is a **Tekton prefetch task**, not a Konflux install and not a hermetic Buildah sandbox.

---

## 1. Decision

| Choice | Resolution |
|--------|------------|
| On-cluster object | Namespaced Tekton **`Task`** `prefetch-dependencies` in `lightwell-tasks` (cluster resolver). **Not** `ClusterTask` (v1beta1). **Not** named `hermeto`. |
| Implementation | Maven `dependency:go-offline` + `-o dependency:resolve` against **in-cluster Nexus**. Image: `ubi9/openjdk-21` (same stream as the seed Dockerfile). |
| Not this task | `quay.io/konflux-ci/hermeto` / Cachi2. Unproven on RHDP CNV; built for hermetic Buildah, not OpenShift BuildConfig. |
| Seed | Pipeline `spring-boot-lw-poc-build-sign` does **not** call it. App `settings.xml` still has `repo.maven.apache.org`. |
| Check (V2-54 / Track 4.2) | Task is wired; prefetch dir is non-empty; public Central / undeclared fetch fails. |
| Mapping appendix | Konflux **Hermeto** → Task `prefetch-dependencies`. Do not rename cluster APIs to Konflux product names. |
| Image build | Still **OpenShift BuildConfig**. Prefetch writes `.m2-offline` into the source workspace so Binary `--from-dir` can consume it after the learner switches the Dockerfile to `mvn -o`. |

---

## 2. Why not real Hermeto

- Q16 allows **Hermeto or equivalent prefetch**.
- Track 4 image build is BuildConfig (Q10 / V2-3). Hermeto’s usual consumer is a hermetic Buildah sandbox.
- Learners must not curl `github.com`; Konflux Hermeto is typically `quay.io/konflux-ci/*`, not a baked Showroom CLI.
- After Track 4.3 tightens `lw-poc-build` egress, public registry pulls for a Konflux image would fail unless pre-mirrored (out of scope for 4.2).

If a later claim proves a Red Hat-shipped Hermeto image and a BuildConfig contract, reopen — do not silently swap the Task.

---

## 3. Fail paths (teaching)

| Input | Result |
|-------|--------|
| `settings.xml` / `pom.xml` still lists `repo.maven.apache.org` (seed) | Fail — public index |
| No `<mirrorOf>*</mirrorOf>` (or `external:*`) | Fail — Maven would still hit Central for plugins |
| No in-cluster Nexus / `lightwell-repo` URL | Fail |
| `mvn -o dependency:resolve` after prefetch | Fail if a declared dep was not in the local repo |
| Prefetch directory empty | Fail |

Do not copy `example-pipeline-snippet.yaml` (wrong name `hermeto`, pip, `runAfter: acs-image-check`).

---

## 4. Unblocks

- [V2-34](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/21) — Track 4 Showroom (4.2 wiring + Dockerfile `mvn -o`)
- [V2-54](https://github.com/NA-FSI-Services/lightwell-tssc-workshop/issues/36) — Validate Job for 4.2
