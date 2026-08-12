# Lightwell Software Supply Chain Security Workshop

## Overview

This lab teaches enterprise software supply chain security using the Red Hat Lightwell Network and the Red Hat Trusted Software Supply Chain (TSSC) toolchain. It exists to close the gap between publishing a CVE fix and getting that fix into production artifacts — a gap that Lightwell Network addresses through its Validated, Remediated, and OSV tiers. Participants will configure Maven and PyPI artifact consumers against an enterprise Nexus proxy, perform OSV-driven exact-version remediation, generate and ingest SBOMs into Red Hat Trusted Profile Analyzer, execute policy-gated Tekton pipelines, sign container images keylessly with Red Hat Trusted Artifact Signer, and promote signed digests via Argo CD — covering a complete Java path (Modules 1–6) and a mirrored Python/FastAPI path (Modules 7–9).

## Target Audience

- **Role:** Application developers, DevSecOps engineers, and platform engineers responsible for artifact governance and supply-chain security
- **Experience level:** Intermediate to Advanced
- **What they already know:** Basic Maven and pip dependency management, Git CLI fundamentals, oc CLI fundamentals (namespaces, configmaps, routes), and RHDP Showroom access
- **What they don't know:** Lightwell Network tier model (Validated/Remediated/OSV), OSV record format and .rhlw-* pin scheme, SBOM generation and ingestion workflows, keyless image signing with Sigstore, Tekton policy gate patterns, and GitOps promotion via Argo CD

## Prerequisites

- Basic Maven and pip package management (can add a dependency, run a build)
- Git CLI: clone, commit, push
- oc CLI: can inspect namespaces, configmaps, and routes
- RHDP Showroom access provisioned before the session
- No prior Lightwell Network, SBOM, or supply-chain security experience required

Prerequisites are assumed and not automatically validated by the lab environment.

## Learning Objectives

1. Verify Lightwell Network tiers and OSV remediation events using the oc CLI and cluster ConfigMaps
2. Configure Maven settings.xml and pip.conf to resolve artifacts from enterprise-proxied Lightwell channels
3. Scaffold Java and Python application repositories from Red Hat Developer Hub Software Templates
4. Analyze OSV fixed events and apply exact-version .rhlw-* pins to pom.xml and requirements.txt
5. Generate CycloneDX and SPDX SBOMs from build output using syft
6. Ingest SBOMs into Red Hat Trusted Profile Analyzer via the v3 API
7. Verify supply-chain policy gates in Tekton pipelines for both the Java and Python application tracks
8. Sign container images keylessly using Red Hat Trusted Artifact Signer (Fulcio, Rekor, TUF)
9. Promote signed image digests to GitOps repositories for Argo CD deployment

## Content Type

Lab (hands-on)

## Products & Technologies

**Red Hat Products:**
- Red Hat Lightwell Network (Validated, Remediated, OSV tiers)
- Red Hat Trusted Profile Analyzer (RHTPA / TPA)
- Red Hat Trusted Artifact Signer (RHTAS) — Fulcio, Rekor, TUF
- Red Hat Advanced Cluster Security (RHACS)
- Red Hat Developer Hub (RHDH) — Software Templates / golden path
- Red Hat OpenShift Container Platform (OCP) — oc CLI
- Red Hat OpenShift Pipelines (Tekton)
- Red Hat OpenShift GitOps (Argo CD)
- Keycloak / SSO — OIDC token provider for RHTPA

**Upstream and Third-Party Technologies:**
- Maven — Java build tool
- pip / PyPI — Python package manager
- Nexus — enterprise artifact manager (proxying packages.redhat.com/lightwell/*)
- Gitea — source and GitOps repositories
- syft — SBOM generator (CycloneDX and SPDX output)
- cosign (Sigstore) v2.4.3 — keyless image signing and verification
- Spring Boot — Java sample application (spring-boot-lw-poc)
- FastAPI — Python sample application (lw-fastapi)
- CycloneDX — SBOM format
- SPDX — SBOM format
- OSV (Open Source Vulnerabilities) schema

## Module Map

| Module | Title | Duration |
|--------|-------|----------|
| 1 | AI Vulnerability Storm and Lightwell Network Overview | 20 min |
| 2 | Enterprise Maven + Artifact Manager Integration | 20 min |
| 3 | Developer Hub Scaffolding (Java Golden Path) | 25 min |
| 4 | OSV Triage and Exact-Version Remediation | 20 min |
| 5 | SBOM Generation and Analysis with RHTPA | 20 min |
| 6 | Pipeline, Signing, Policy, and GitOps Promotion (Java) | 45 min |
| 7 | PyPI Validated + FastAPI (Python Track Kickoff) | 30 min |
| 8 | Remediated PyPI + SPDX/SBOM to RHTPA | 25 min |
| 9 | Python Pipeline, Sign, Policy, and GitOps Promotion | 40 min |
| — | **Total hands-on** | **245 min (~4 hours)** |
| — | Intro / presentation | ~15 min (Module 1 conceptual) |
| — | **Total lab** | **~4.5 hours** |

## Difficulty Level

Intermediate to Advanced

## Environment

**Learner view:** Learners access the lab via RHDP Showroom. When the lab starts, a shared OpenShift cluster is pre-provisioned with all required operators and services already running: OpenShift Pipelines, OpenShift GitOps (Argo CD), Red Hat Advanced Cluster Security, Red Hat Trusted Profile Analyzer, Red Hat Developer Hub, Keycloak (SSO), Gitea, Nexus, Red Hat Trusted Artifact Signer, and an OpenShift BuildConfig. Per-learner namespaces (`lw-poc-<username>` for Java and `lw-fastapi-<username>` for Python) are pre-created with seeded application repositories and ConfigMaps containing discovery URLs. Learners interact through a combination of the Showroom terminal (oc CLI, mvn, pip, cosign, syft, curl, git) and GUIs (RHDH, RHTPA, Argo CD console, OpenShift Console).

**Automation needed:** Yes

The following must be provisioned before learners begin:
- OpenShift cluster with all operators installed (Pipelines, GitOps, RHACS, RHTPA, RHDH, RHTAS)
- Keycloak realm and demo user accounts
- Nexus instance configured with Lightwell proxy repositories (validated, remediated, OSV tiers) backed by packages.redhat.com/lightwell/*
- Gitea instance with seeded Java (spring-boot-lw-poc) and Python (lw-fastapi) repositories per learner
- ConfigMaps per namespace: lightwell-channels, demo-userinfo-rhdh, demo-userinfo-keycloak, lightwell-pip-settings
- Per-learner namespaces: lw-poc-<username>, lw-fastapi-<username>
- Tekton Pipeline definitions: dep-gate (Java), lightwell-python-dep-gate (Python)
- GitOps Helm repositories seeded in Gitea per learner
- RHDH Software Templates loaded: lightwell-java-service, lightwell-python-service
- cosign binary available in Showroom home directory
- syft binary available in Showroom home directory
- OSV evaluation scripts pre-staged: tools/osv-eval/scripts/

## Infrastructure Requirements

- **Cloud provider:** CNV (default)
- **Cluster type:** TBD — confirmed in infrastructure phase (likely multinode given operator stack)
- **OCP version:** TBD — confirmed in infrastructure phase (minimum 4.14 expected for Pipelines v1 GA; exact version not stated in content)
- **Topology:** Per-student (each learner gets dedicated namespaces lw-poc-<username> and lw-fastapi-<username>)
- **Sizing:** TBD — confirmed in infrastructure phase. Heavy operator stack (RHACS, RHTPA, RHDH, RHTAS, Pipelines, GitOps) plus Nexus and Gitea with persistent storage suggests significant worker capacity. Rough estimate: 3 control plane + 4–6 workers at 16 CPU / 64GB RAM / 200GB disk each.
- **Automation approach:** Ansible (setup) + GitOps Helm + Argo CD (per-learner resources)
- **AI/MaaS:** None
- **External services:** packages.redhat.com (Lightwell package registry, proxied via Nexus), github.com (cosign binary download from sigstore/cosign releases)
- **AAP version:** Not applicable (Ansible used for provisioning only, not as a product under instruction)
- **Non-GA products:** None (all products are GA) — TBD, confirmed in infrastructure phase if RHTPA version requires verification

## Assessment Strategy

This lab uses observable outcomes rather than automated solve/validate buttons (classic Showroom pattern). Each module closes with a verifiable CLI or UI result:

- **Module 1:** `oc get configmap lightwell-channels` output visible; OSV record inspected in terminal
- **Module 2:** `mvn clean verify` output shows artifacts resolved from lightwell-validated and lightwell-remediated Nexus repos
- **Module 3:** Scaffolded repo cloned; `mvn clean verify` passes on RHDH-generated project
- **Module 4:** `mvn clean verify` dependency tree shows `commons-lang3:3.14.0.rhlw-00001`
- **Module 5:** RHTPA UI shows ingested SBOM; curl response returns 201
- **Module 6:** PipelineRun gate-status=passed; cosign verify succeeds; Argo CD shows synced application
- **Module 7:** pip install resolves from lightwell-python-validated Nexus index; scaffolded FastAPI repo created in RHDH
- **Module 8:** syft generates SPDX and CycloneDX; RHTPA ingestion returns 201
- **Module 9:** lightwell-python-dep-gate PipelineRun passes; cosign verify succeeds; Argo CD syncs Python app
