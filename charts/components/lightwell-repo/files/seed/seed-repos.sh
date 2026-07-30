#!/usr/bin/env bash
# Bootstrap Nexus repos + seed Validated / Remediated / OSV / CycloneDX content.
# Intended to run in Job lightwell-repo-seed (ServiceAccount with pods/exec).
# Never embeds LW_* or Nexus admin passwords in Git.
set -euo pipefail

NAMESPACE="${NAMESPACE:-lightwell-repo}"
NEXUS_SVC="${NEXUS_SVC:-http://nexus:8081}"
MODE="${LIGHTWELL_REPO_MODE:-seeded}"
SEED_DIR="${SEED_DIR:-/seed}"
OSV_ID="${OSV_ID:-LW-DEMO-0001}"
OSV_PATH="osv/java/remediated/${OSV_ID}.json"

log() { echo "[lightwell-repo-seed] $*"; }

wait_nexus() {
  log "Waiting for Nexus REST at ${NEXUS_SVC} ..."
  for _ in $(seq 1 90); do
    if curl -sf "${NEXUS_SVC}/service/rest/v1/status" >/dev/null 2>&1; then
      log "Nexus is Ready"
      return 0
    fi
    sleep 10
  done
  log "ERROR: Nexus did not become Ready"
  exit 1
}

resolve_admin_password() {
  if [[ -n "${NEXUS_ADMIN_PASSWORD:-}" ]]; then
    log "Using NEXUS_ADMIN_PASSWORD from environment / Secret"
    return 0
  fi
  log "Capturing Nexus admin password from pod (first-boot file) ..."
  local pod
  for _ in $(seq 1 60); do
    pod="$(oc get pods -n "${NAMESPACE}" -l app=nexus -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)"
    if [[ -n "${pod}" ]]; then
      if NEXUS_ADMIN_PASSWORD="$(oc exec -n "${NAMESPACE}" "${pod}" -- cat /nexus-data/admin.password 2>/dev/null)"; then
        export NEXUS_ADMIN_PASSWORD
        log "Captured admin password from ${pod}"
        return 0
      fi
    fi
    sleep 10
  done
  log "ERROR: could not read /nexus-data/admin.password — set Secret nexus-admin-credentials"
  exit 1
}

AUTH=()
setup_auth() {
  AUTH=(-u "${NEXUS_ADMIN_USER:-admin}:${NEXUS_ADMIN_PASSWORD}")
}

# Ignore HTTP 400 (already exists) so Job is re-runnable
curl_ok() {
  local code
  code="$(curl -sS -o /tmp/nexus-out -w '%{http_code}' "${AUTH[@]}" "$@" || true)"
  if [[ "${code}" =~ ^2 ]] || [[ "${code}" == "400" ]]; then
    return 0
  fi
  log "WARN: HTTP ${code} for $* — body:"
  cat /tmp/nexus-out || true
  return 0
}

create_maven_proxy() {
  local name="$1" url="$2"
  log "Maven proxy repo: ${name} -> ${url}"
  curl_ok -H 'Content-Type: application/json' \
    -X POST "${NEXUS_SVC}/service/rest/v1/repositories/maven/proxy" \
    -d "{\"name\":\"${name}\",\"online\":true,\"storage\":{\"blobStoreName\":\"default\",\"strictContentTypeValidation\":true,\"writePolicy\":\"ALLOW\"},\"proxy\":{\"remoteUrl\":\"${url}\",\"contentMaxAge\":1440,\"metadataMaxAge\":1440},\"negativeCache\":{\"enabled\":true,\"timeToLive\":1440},\"httpClient\":{\"blocked\":false,\"autoBlock\":true,\"authentication\":{\"type\":\"username\",\"username\":\"${LW_USERNAME}\",\"password\":\"${LW_PASSWORD}\"}},\"maven\":{\"versionPolicy\":\"RELEASE\",\"layoutPolicy\":\"PERMISSIVE\"}}"
}

create_maven_hosted() {
  local name="$1"
  log "Maven hosted repo: ${name}"
  curl_ok -H 'Content-Type: application/json' \
    -X POST "${NEXUS_SVC}/service/rest/v1/repositories/maven/hosted" \
    -d "{\"name\":\"${name}\",\"online\":true,\"storage\":{\"blobStoreName\":\"default\",\"strictContentTypeValidation\":true,\"writePolicy\":\"ALLOW\"},\"maven\":{\"versionPolicy\":\"RELEASE\",\"layoutPolicy\":\"PERMISSIVE\"}}"
}

create_raw_hosted() {
  local name="$1"
  log "Raw hosted repo: ${name}"
  curl_ok -H 'Content-Type: application/json' \
    -X POST "${NEXUS_SVC}/service/rest/v1/repositories/raw/hosted" \
    -d "{\"name\":\"${name}\",\"online\":true,\"storage\":{\"blobStoreName\":\"default\",\"strictContentTypeValidation\":false,\"writePolicy\":\"ALLOW\"},\"raw\":{\"contentDisposition\":\"ATTACHMENT\"}}"
}

create_raw_proxy() {
  local name="$1" url="$2"
  log "Raw proxy repo: ${name} -> ${url}"
  curl_ok -H 'Content-Type: application/json' \
    -X POST "${NEXUS_SVC}/service/rest/v1/repositories/raw/proxy" \
    -d "{\"name\":\"${name}\",\"online\":true,\"storage\":{\"blobStoreName\":\"default\",\"strictContentTypeValidation\":false,\"writePolicy\":\"ALLOW\"},\"proxy\":{\"remoteUrl\":\"${url}\",\"contentMaxAge\":1440,\"metadataMaxAge\":1440},\"negativeCache\":{\"enabled\":true,\"timeToLive\":1440},\"httpClient\":{\"blocked\":false,\"autoBlock\":true,\"authentication\":{\"type\":\"username\",\"username\":\"${LW_USERNAME}\",\"password\":\"${LW_PASSWORD}\"}},\"raw\":{\"contentDisposition\":\"ATTACHMENT\"}}"
}

upload_maven() {
  local repo="$1" group_id="$2" artifact_id="$3" version="$4" pom="$5" jar="$6"
  log "Upload Maven ${group_id}:${artifact_id}:${version} -> ${repo}"
  curl_ok -H 'accept: application/json' \
    -F "maven2.groupId=${group_id}" \
    -F "maven2.artifactId=${artifact_id}" \
    -F "maven2.version=${version}" \
    -F "maven2.asset1=@${jar}" \
    -F "maven2.asset1.extension=jar" \
    -F "maven2.asset2=@${pom}" \
    -F "maven2.asset2.extension=pom" \
    "${NEXUS_SVC}/service/rest/v1/components?repository=${repo}"
}

upload_raw() {
  local repo="$1" path="$2" file="$3"
  log "Upload raw ${repo}/${path}"
  curl_ok -X PUT --data-binary @"${file}" \
    -H 'Content-Type: application/octet-stream' \
    "${NEXUS_SVC}/repository/${repo}/${path}"
}

prepare_jar() {
  local out="$1"
  if [[ -f "${SEED_DIR}/workshop-stub.jar" ]]; then
    cp "${SEED_DIR}/workshop-stub.jar" "${out}"
  elif [[ -f "${SEED_DIR}/workshop-stub.jar.b64" ]]; then
    base64 -d < "${SEED_DIR}/workshop-stub.jar.b64" > "${out}"
  else
    log "ERROR: missing workshop-stub.jar(.b64) in ${SEED_DIR}"
    exit 1
  fi
}

seed_content() {
  local work
  work="$(mktemp -d)"
  prepare_jar "${work}/stub.jar"

  # Learner-facing repo keys (same names as Maven settings.xml)
  local validated_repo="${VALIDATED_REPO:-lightwell-java-validated}"
  local remediated_repo="${REMEDIATED_REPO:-lightwell-java-remediated}"
  local osv_repo="${OSV_REPO:-lightwell-osv-java-remediated}"

  upload_maven "${validated_repo}" "org.springframework" "spring-core" "5.3.18" \
    "${SEED_DIR}/spring-core-5.3.18.pom" "${work}/stub.jar"
  upload_maven "${remediated_repo}" "org.springframework" "spring-core" "5.3.18.rhlw-00003" \
    "${SEED_DIR}/spring-core-5.3.18.rhlw-00003.pom" "${work}/stub.jar"

  upload_maven "${validated_repo}" "org.apache.commons" "commons-lang3" "3.14.0" \
    "${SEED_DIR}/commons-lang3-3.14.0.pom" "${work}/stub.jar"
  upload_maven "${remediated_repo}" "org.apache.commons" "commons-lang3" "3.14.0.rhlw-00001" \
    "${SEED_DIR}/commons-lang3-3.14.0.rhlw-00001.pom" "${work}/stub.jar"

  upload_raw "${osv_repo}" "${OSV_PATH}" "${SEED_DIR}/${OSV_ID}.json"
  upload_raw "${osv_repo}" "sbom/java/validated/org.springframework/spring-core/5.3.18.cdx.json" \
    "${SEED_DIR}/spring-core-5.3.18.cdx.json"
  upload_raw "${osv_repo}" "sbom/java/remediated/org.springframework/spring-core/5.3.18.rhlw-00003.cdx.json" \
    "${SEED_DIR}/spring-core-5.3.18.rhlw-00003.cdx.json"

  log "Seeded Maven + OSV (${OSV_PATH}) + CycloneDX SBOMs"
}

create_repos() {
  if [[ "${MODE}" == "proxy" ]]; then
    : "${LW_USERNAME:?set LW_USERNAME for proxy mode}"
    : "${LW_PASSWORD:?set LW_PASSWORD for proxy mode}"
    create_maven_proxy "${VALIDATED_REPO:-lightwell-java-validated}" \
      "${VALIDATED_REMOTE:-https://packages.redhat.com/lightwell/java/validated}/"
    create_maven_proxy "${REMEDIATED_REPO:-lightwell-java-remediated}" \
      "${REMEDIATED_REMOTE:-https://packages.redhat.com/lightwell/java/remediated}/"
    create_raw_proxy "${OSV_REPO:-lightwell-osv-java-remediated}" \
      "${OSV_REMOTE:-https://packages.redhat.com/lightwell/osv/java/remediated}/"
    log "Proxy repos created — live LWN content (credentials from Secret)"
  else
    create_maven_hosted "${VALIDATED_REPO:-lightwell-java-validated}"
    create_maven_hosted "${REMEDIATED_REPO:-lightwell-java-remediated}"
    create_raw_hosted "${OSV_REPO:-lightwell-osv-java-remediated}"
    # Also create *-hosted aliases documented in channels ConfigMap
    create_maven_hosted "${VALIDATED_HOSTED:-lightwell-java-validated-hosted}"
    create_maven_hosted "${REMEDIATED_HOSTED:-lightwell-java-remediated-hosted}"
    create_raw_hosted "${OSV_HOSTED:-lightwell-osv-java-remediated-hosted}"
  fi
}

main() {
  log "mode=${MODE} nexus=${NEXUS_SVC} namespace=${NAMESPACE}"
  wait_nexus
  resolve_admin_password
  setup_auth
  create_repos
  if [[ "${MODE}" == "seeded" ]]; then
    seed_content
  elif [[ "${SEED_OSV_IN_PROXY:-false}" == "true" ]]; then
    log "Proxy mode with optional local OSV/SBOM overlay skipped (SEED_OSV_IN_PROXY)"
  fi
  log "Done"
}

main "$@"
