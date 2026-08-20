#!/usr/bin/env bash
# Copy RHTAS TUF Fulcio CA + Rekor public key into Secret rhtas-tuf-keys.
# Chart injects these into ImagePolicy; learners never paste PEMs.
#
# RHTAS TUF serves /root.json (not / — that is Apache 403) and hashed target
# names (HASH.fulcio_v1.crt.pem). The Route is tuf-<suffix>, not name tuf.
set -euo pipefail

if ! command -v oc >/dev/null 2>&1; then
  curl -fsSL -o /tmp/oc.tgz \
    https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable/openshift-client-linux.tar.gz
  tar -C /usr/local/bin -xzf /tmp/oc.tgz oc
fi
if ! command -v python3 >/dev/null 2>&1; then
  dnf install -y -q python3 && dnf clean all
fi

SVC="http://${TUF_SERVICE}.${RHTAS_NAMESPACE}.svc:${TUF_PORT}"

discover_tuf_host() {
  oc -n "${RHTAS_NAMESPACE}" get route \
    -o jsonpath='{range .items[*]}{.spec.to.name}{"\t"}{.spec.host}{"\n"}{end}' \
    | awk -F'\t' '$1=="tuf"{print $2; exit}'
}

tuf_ready() {
  curl -fsS --max-time 5 "${SVC}/root.json" >/dev/null 2>&1 && return 0
  [[ -n "${TUF_HOST}" ]] || return 1
  curl -fsSk --max-time 5 "https://${TUF_HOST}/root.json" >/dev/null 2>&1
}

echo "Waiting for TUF in ${RHTAS_NAMESPACE} (up to ${WAIT_SECONDS}s)..."
deadline=$((SECONDS + WAIT_SECONDS))
TUF_HOST=""
while (( SECONDS < deadline )); do
  if oc -n "${RHTAS_NAMESPACE}" get securesign "${RHTAS_NAME}" >/dev/null 2>&1; then
    TUF_HOST="$(discover_tuf_host || true)"
    if tuf_ready; then
      echo "TUF ready (host=${TUF_HOST:-in-cluster})"
      break
    fi
  fi
  sleep 5
done

WORKDIR=/tmp/tuf-keys
mkdir -p "${WORKDIR}"

# TUF target files are HASH.<logical-name>. Parse the directory listing.
fetch_by_suffix() {
  local dest="$1"
  local suffix="$2"
  local href=""
  href="$(curl -fsS --max-time 20 "${SVC}/targets/" \
    | grep -oE "href=\"[^\"]*${suffix}\"" | head -1 | sed 's/^href="//;s/"$//')" || true
  if [[ -n "${href}" ]] && curl -fsS --max-time 20 -o "${dest}" "${SVC}/targets/${href}"; then
    echo "Fetched ${suffix} from in-cluster TUF (${href})"
    return 0
  fi
  if [[ -n "${TUF_HOST}" ]]; then
    href="$(curl -fsSk --max-time 20 "https://${TUF_HOST}/targets/" \
      | grep -oE "href=\"[^\"]*${suffix}\"" | head -1 | sed 's/^href="//;s/"$//')" || true
    if [[ -n "${href}" ]] && curl -fsSk --max-time 20 -o "${dest}" "https://${TUF_HOST}/targets/${href}"; then
      echo "Fetched ${suffix} from TUF Route (${href})"
      return 0
    fi
  fi
  return 1
}

FULCIO_PEM="${WORKDIR}/fulcio_v1.crt.pem"
REKOR_PEM="${WORKDIR}/rekor.pub"

if ! fetch_by_suffix "${FULCIO_PEM}" "fulcio_v1.crt.pem" || ! fetch_by_suffix "${REKOR_PEM}" "rekor.pub"; then
  echo "TUF HTTP targets missed — scanning Secrets in ${RHTAS_NAMESPACE}"
  python3 - "${RHTAS_NAMESPACE}" "${WORKDIR}" <<'PY'
import base64, json, os, subprocess, sys
ns, out = sys.argv[1], sys.argv[2]
names = subprocess.check_output(
    ["oc", "-n", ns, "get", "secret", "-o", "jsonpath={.items[*].metadata.name}"],
    text=True,
).split()
fulcio = rekor = None
for name in names:
    raw = subprocess.check_output(["oc", "-n", ns, "get", "secret", name, "-o", "json"], text=True)
    data = json.loads(raw).get("data") or {}
    for k, v in data.items():
        try:
            text = base64.b64decode(v).decode("utf-8", "replace")
        except Exception:
            continue
        if "BEGIN CERTIFICATE" in text and fulcio is None:
            fulcio = text
        if ("BEGIN PUBLIC KEY" in text or "BEGIN REKOR" in text) and rekor is None and "BEGIN CERTIFICATE" not in text:
            rekor = text
if not fulcio or not rekor:
    sys.exit("Could not find Fulcio CA and Rekor public key in TUF HTTP or Secrets")
open(os.path.join(out, "fulcio_v1.crt.pem"), "w").write(fulcio if fulcio.endswith("\n") else fulcio + "\n")
open(os.path.join(out, "rekor.pub"), "w").write(rekor if rekor.endswith("\n") else rekor + "\n")
print("Wrote PEMs from Secret scan")
PY
fi

if [[ ! -s "${FULCIO_PEM}" || ! -s "${REKOR_PEM}" ]]; then
  echo "Fulcio CA or Rekor key missing after fetch" >&2
  exit 1
fi

oc -n "${ADMISSION_NAMESPACE}" create secret generic "${SECRET_NAME}" \
  --from-file=fulcio_v1.crt.pem="${FULCIO_PEM}" \
  --from-file=rekor.pub="${REKOR_PEM}" \
  --dry-run=client -o yaml | oc apply -f -

echo "Secret ${SECRET_NAME} updated in ${ADMISSION_NAMESPACE}"
