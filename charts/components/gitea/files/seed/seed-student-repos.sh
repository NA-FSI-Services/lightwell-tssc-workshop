#!/usr/bin/env bash
# Create workshop admin (if needed), student users, and seed application repos.
set -euo pipefail

: "${GITEA_URL:?}"
: "${GITEA_NAMESPACE:?}"
: "${GITEA_DEPLOYMENT:?}"
: "${ADMIN_USER:?}"
: "${ADMIN_PASSWORD:?}"
: "${ADMIN_EMAIL:?}"
: "${REPO_NAME:?}"
: "${REPO_DESCRIPTION:?}"
: "${DEFAULT_BRANCH:?}"
: "${STUDENTS_JSON:?}"
: "${SEED_DIR:=/seed}"

API="${GITEA_URL%/}/api/v1"
WORKDIR="$(mktemp -d)"
trap 'rm -rf "${WORKDIR}"' EXIT

echo "Waiting for Gitea at ${GITEA_URL} ..."
for i in $(seq 1 90); do
  if curl -fsS "${GITEA_URL%/}/api/healthz" >/dev/null 2>&1; then
    echo "Gitea is healthy."
    break
  fi
  if [[ "${i}" -eq 90 ]]; then
    echo "ERROR: Gitea did not become healthy in time" >&2
    exit 1
  fi
  sleep 5
done

POD="$(oc -n "${GITEA_NAMESPACE}" get pod -l "app=${GITEA_DEPLOYMENT}" \
  -o jsonpath='{.items[0].metadata.name}')"
if [[ -z "${POD}" ]]; then
  echo "ERROR: no Gitea pod found in ${GITEA_NAMESPACE}" >&2
  exit 1
fi

ensure_user() {
  local user="$1" pass="$2" email="$3" full_name="$4" admin_flag="$5"
  local args=(admin user create --username "${user}" --password "${pass}"
    --email "${email}" --must-change-password=false)
  if [[ -n "${full_name}" ]]; then
    args+=(--full-name "${full_name}")
  fi
  if [[ "${admin_flag}" == "true" ]]; then
    args+=(--admin)
  fi
  if oc -n "${GITEA_NAMESPACE}" exec "${POD}" -- gitea "${args[@]}" 2>/dev/null; then
    echo "Created user ${user}"
  else
    echo "User ${user} already exists (or create skipped) — continuing"
  fi
}

ensure_user "${ADMIN_USER}" "${ADMIN_PASSWORD}" "${ADMIN_EMAIL}" "Gitea Admin" "true"

auth_header() {
  # Basic auth for Gitea API
  printf 'Authorization: Basic %s' "$(printf '%s:%s' "$1" "$2" | base64 -w0 2>/dev/null || printf '%s:%s' "$1" "$2" | base64)"
}

ensure_repo() {
  local owner="$1" pass="$2"
  local code
  code="$(curl -sS -o /tmp/gitea-repo.json -w '%{http_code}' \
    -H "$(auth_header "${owner}" "${pass}")" \
    -H 'Content-Type: application/json' \
    "${API}/repos/${owner}/${REPO_NAME}" || true)"
  if [[ "${code}" == "200" ]]; then
    echo "Repo ${owner}/${REPO_NAME} already exists"
    return 0
  fi
  code="$(curl -sS -o /tmp/gitea-repo-create.json -w '%{http_code}' \
    -X POST \
    -H "$(auth_header "${owner}" "${pass}")" \
    -H 'Content-Type: application/json' \
    -d "$(printf '{"name":"%s","description":"%s","private":false,"auto_init":false,"default_branch":"%s"}' \
      "${REPO_NAME}" "${REPO_DESCRIPTION}" "${DEFAULT_BRANCH}")" \
    "${API}/user/repos")"
  if [[ "${code}" != "201" ]]; then
    echo "ERROR: create repo ${owner}/${REPO_NAME} failed HTTP ${code}" >&2
    cat /tmp/gitea-repo-create.json >&2 || true
    exit 1
  fi
  echo "Created repo ${owner}/${REPO_NAME}"
}

push_seed() {
  local owner="$1" pass="$2"
  local repo_dir="${WORKDIR}/${owner}-${REPO_NAME}"
  rm -rf "${repo_dir}"
  mkdir -p "${repo_dir}"
  cp -a "${SEED_DIR}/repo/." "${repo_dir}/"
  (
    cd "${repo_dir}"
    git init -b "${DEFAULT_BRANCH}"
    git config user.email "${owner}@workshop.local"
    git config user.name "${owner}"
    git add .
    git commit -m "Seed student lab repository for Lightwell Module 5"
    git remote add origin "https://${owner}:${pass}@${GITEA_URL#https://}/${owner}/${REPO_NAME}.git"
    export GIT_TERMINAL_PROMPT=0
    export GIT_SSL_NO_VERIFY="${GIT_SSL_NO_VERIFY:-true}"
    # Retry push while Gitea finishes repo creation
    for i in $(seq 1 12); do
      if git -c http.sslVerify=false push -u origin "${DEFAULT_BRANCH}"; then
        echo "Pushed seed to ${owner}/${REPO_NAME}"
        return 0
      fi
      sleep 5
    done
    echo "ERROR: git push failed for ${owner}/${REPO_NAME}" >&2
    exit 1
  )
}

# STUDENTS_JSON: [{"username":"...","password":"...","email":"...","fullName":"..."}, ...]
if ! command -v python3 >/dev/null 2>&1; then
  echo "ERROR: python3 required to parse STUDENTS_JSON" >&2
  exit 1
fi

python3 - <<'PY' >"${WORKDIR}/students.tsv"
import json, os
students = json.loads(os.environ["STUDENTS_JSON"])
for s in students:
    print("\t".join([
        s["username"],
        s["password"],
        s.get("email", f'{s["username"]}@workshop.local'),
        s.get("fullName", s["username"]),
    ]))
PY

while IFS=$'\t' read -r user pass email full_name; do
  [[ -z "${user}" ]] && continue
  ensure_user "${user}" "${pass}" "${email}" "${full_name}" "false"
  ensure_repo "${user}" "${pass}"
  push_seed "${user}" "${pass}"
  echo "STUDENT_REPO_URL=${GITEA_URL%/}/${user}/${REPO_NAME}.git"
done <"${WORKDIR}/students.tsv"

echo "gitea-student-repo-seed: complete"
