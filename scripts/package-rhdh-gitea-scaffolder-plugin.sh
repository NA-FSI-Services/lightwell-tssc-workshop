#!/usr/bin/env bash
# Rebuild + publish the RHDH dynamic plugin that registers publish:gitea.
# Usage:
#   ./scripts/package-rhdh-gitea-scaffolder-plugin.sh [version]
# Default version: 0.2.23 (@backstage/plugin-scaffolder-backend-module-gitea)
set -euo pipefail

VERSION="${1:-0.2.23}"
TAG="rhdh-gitea-scaffolder-${VERSION}"
WORKDIR="$(mktemp -d "${TMPDIR:-/tmp}/rhdh-gitea-plugin.XXXXXX")"
cleanup() { rm -rf "${WORKDIR}"; }
trap cleanup EXIT

echo "==> Packaging @backstage/plugin-scaffolder-backend-module-gitea@${VERSION}"
cd "${WORKDIR}"
npm pack "@backstage/plugin-scaffolder-backend-module-gitea@${VERSION}" >/dev/null
mkdir pkg && tar -xzf "backstage-plugin-scaffolder-backend-module-gitea-${VERSION}.tgz" -C pkg
cd pkg/package

python3 - <<'PY'
import json
from pathlib import Path
p = Path("package.json")
d = json.loads(p.read_text())
# rhdh-cli requires string export targets
d["exports"] = {".": "./dist/index.cjs.js", "./package.json": "./package.json"}
p.write_text(json.dumps(d, indent=2) + "\n")
PY

npm install --omit=dev --legacy-peer-deps >/dev/null
yarn install >/dev/null
npx --yes @red-hat-developer-hub/cli@latest plugin export --no-build --clean

cd dist-dynamic
PACK_JSON="$(npm pack --json)"
FILENAME="$(python3 -c 'import json,sys; print(json.load(sys.stdin)[0]["filename"])' <<<"${PACK_JSON}")"
INTEGRITY="$(python3 -c 'import json,sys; print(json.load(sys.stdin)[0]["integrity"])' <<<"${PACK_JSON}")"
TGZ="$(pwd)/${FILENAME}"

echo "==> Built ${TGZ}"
echo "==> integrity: ${INTEGRITY}"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if gh release view "${TAG}" --repo NA-FSI-Services/lightwell-tssc-workshop >/dev/null 2>&1; then
  gh release upload "${TAG}" "${TGZ}" --clobber --repo NA-FSI-Services/lightwell-tssc-workshop
else
  gh release create "${TAG}" "${TGZ}" \
    --repo NA-FSI-Services/lightwell-tssc-workshop \
    --title "RHDH dynamic plugin: publish:gitea (${VERSION})" \
    --notes "Prebuilt \`publish:gitea\` dynamic plugin from \`@backstage/plugin-scaffolder-backend-module-gitea@${VERSION}\`.

Integrity: \`${INTEGRITY}\`"
fi

echo
echo "Update charts/components/rhdh/values.yaml dynamicPlugins.giteaScaffolder:"
echo "  package: https://github.com/NA-FSI-Services/lightwell-tssc-workshop/releases/download/${TAG}/${FILENAME}"
echo "  integrity: ${INTEGRITY}"
