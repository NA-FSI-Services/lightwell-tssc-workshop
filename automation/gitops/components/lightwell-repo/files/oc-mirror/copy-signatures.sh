#!/usr/bin/env bash
# #63: Nexus 3.70 Docker dest has no OCI referrers. oc-mirror v2 copies the image
# but not signatures. Copy tag-based cosign artifacts (.sig/.att/.sbom) onto dest.
set -euo pipefail

DEST_HOST="${DEST_HOST:?DEST_HOST is required}"
CFG="${IMAGESET_PATH:-/imageset/imageset-config.yaml}"

if [[ ! -f "$CFG" ]]; then
  echo "ImageSet not mounted at ${CFG}" >&2
  exit 1
fi

# First additionalImages name: (skip comments that mention "name").
PIN="$(
  grep -v '^[[:space:]]*#' "$CFG" \
    | grep -m1 'name:' \
    | sed 's/^[[:space:]]*-[[:space:]]*//; s/^name:[[:space:]]*//; s/["'\'']//g; s/[[:space:]]*$//'
)"

if [[ -z "$PIN" || "$PIN" == *REPLACE_ME* ]]; then
  echo "ImageSet still has REPLACE_ME or an empty name: ${PIN:-<empty>}" >&2
  exit 1
fi

# registry.access.redhat.com/hi/openjdk:21-runtime@sha256:... → dest path after host
path_and_ref="${PIN#*/}"
DST="${DEST_HOST}/${path_and_ref}"

echo "Copying signatures:"
echo "  source: ${PIN}"
echo "  dest:   ${DST}"
echo "DEST_PULLSPEC=${DST}"

cosign copy --allow-insecure-registry "${PIN}" "${DST}"

echo "Signature copy complete."
