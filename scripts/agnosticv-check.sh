#!/usr/bin/env bash
# AgnosticV draft validation (issue #72).
# Checks folder leaf structure, YAML parse, UUID, category, and stage merge.
#
# Usage:
#   scripts/agnosticv-check.sh
#   scripts/agnosticv-check.sh <files...>   # skip if change set unrelated
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT}"

LEAF="agnosticv/lightwell-tssc-workshop"
COMMON="${LEAF}/common.yaml"
DESC="${LEAF}/description.adoc"
DEV="${LEAF}/dev.yaml"
PROD="${LEAF}/prod.yaml"

failed=0
err() { echo "agnosticv-check: ERROR: $*" >&2; failed=1; }
ok() { echo "agnosticv-check: $*"; }

# Optional: skip when filenames are passed and none touch AgV drafts / this script
if [[ $# -gt 0 ]]; then
  relevant=0
  for f in "$@"; do
    case "${f}" in
      agnosticv/*|scripts/agnosticv-check.sh|DEVELOPMENT-PLAN.md|agnosticv/SUBMISSION.md)
        relevant=1
        break
        ;;
    esac
  done
  if [[ "${relevant}" -eq 0 ]]; then
    ok "skip (no AgnosticV paths in change set)"
    exit 0
  fi
fi

for f in "${COMMON}" "${DESC}" "${DEV}" "${PROD}"; do
  if [[ ! -f "${f}" ]]; then
    err "missing required file: ${f}"
  else
    ok "present: ${f}"
  fi
done

if [[ "${failed}" -ne 0 ]]; then
  exit 1
fi

ruby - "${ROOT}" <<'RUBY'
require "yaml"
require "pathname"
require "date"

root = Pathname.new(ARGV[0])
leaf = root / "agnosticv" / "lightwell-tssc-workshop"
common_path = leaf / "common.yaml"
dev_path = leaf / "dev.yaml"
prod_path = leaf / "prod.yaml"
placeholder = "00000000-0000-4000-8000-000000000009"
uuid_re = /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/
valid_categories = %w[Workshops Labs Demos Open_Environments Brand_Events]
failed = 0

def err(msg)
  warn "agnosticv-check: ERROR: #{msg}"
  $failed = 1
end

def ok(msg)
  puts "agnosticv-check: #{msg}"
end

$failed = 0

def load_yaml(path)
  data = YAML.safe_load(path.read, permitted_classes: [Date, Time], aliases: true)
  if data.nil?
    err("#{path} is empty")
    return nil
  end
  unless data.is_a?(Hash)
    err("#{path} must be a mapping at the top level")
    return nil
  end
  ok("YAML parse OK: #{path.relative_path_from(Pathname.pwd)}")
  data
rescue StandardError => e
  err("YAML parse failed for #{path}: #{e.message}")
  nil
end

def deep_merge(base, overlay)
  out = Marshal.load(Marshal.dump(base))
  overlay.each do |key, value|
    if out[key].is_a?(Hash) && value.is_a?(Hash)
      out[key] = deep_merge(out[key], value)
    else
      out[key] = Marshal.load(Marshal.dump(value))
    end
  end
  out
end

Dir.chdir(root)

common = load_yaml(common_path)
dev = load_yaml(dev_path)
prod = load_yaml(prod_path)
exit 1 if common.nil?

meta = common["__meta__"]
unless meta.is_a?(Hash)
  err("common.yaml missing __meta__ mapping")
  exit 1
end

uuid = meta["asset_uuid"]
if uuid.nil? || uuid.to_s.empty?
  err("common.yaml missing __meta__.asset_uuid")
elsif uuid.to_s == placeholder
  err("asset_uuid is still the placeholder (#{placeholder})")
elsif uuid.to_s !~ uuid_re
  err("asset_uuid must be lowercase RFC 4122 UUID, got: #{uuid}")
else
  ok("UUID format valid: #{uuid}")
end

collisions = []
Pathname.glob(root.join("**/common.yaml")).each do |path|
  next if path.realpath == common_path.realpath

  begin
    other = YAML.safe_load(path.read, permitted_classes: [Date, Time], aliases: true) || {}
  rescue StandardError
    next
  end
  other_uuid = other.dig("__meta__", "asset_uuid")
  collisions << path.to_s if other_uuid && other_uuid.to_s == uuid.to_s
end
if collisions.any?
  err("UUID collision with #{collisions.join(', ')}")
else
  ok("UUID is unique in-repo")
end

catalog = meta["catalog"]
unless catalog.is_a?(Hash)
  err("common.yaml missing __meta__.catalog")
else
  category = catalog["category"]
  if valid_categories.include?(category)
    ok("category valid: #{category}")
  else
    err("invalid __meta__.catalog.category: #{category.inspect} (expected one of #{valid_categories.join(', ')})")
  end
end

gitops_url = common["ocp4_workload_field_content_gitops_repo_url"].to_s
gitops_path = common["ocp4_workload_field_content_gitops_repo_path"].to_s
gitops_rev = common["ocp4_workload_field_content_gitops_repo_revision"].to_s

if gitops_url.include?("NA-FSI-Services/lightwell-tssc-workshop")
  ok("gitops repo URL OK")
else
  err("gitops repo URL must reference NA-FSI-Services/lightwell-tssc-workshop")
end

if gitops_path == "charts/root-app"
  ok("gitops path OK")
else
  err("gitops path must be charts/root-app, got #{gitops_path.inspect}")
end

if gitops_rev == "main"
  ok("gitops revision OK")
else
  err("gitops revision must be main, got #{gitops_rev.inspect}")
end

anarchy_ns = meta.dig("anarchy", "namespace")
if anarchy_ns
  err("__meta__.anarchy.namespace must not be set in catalog common.yaml")
else
  ok("anarchy.namespace not defined (correct)")
end

slug = leaf.basename.to_s
if slug.length > 50
  err("catalog directory name too long (#{slug.length} > 50): #{slug}")
else
  ok("catalog directory name length OK (#{slug.length}/50): #{slug}")
end

unless dev.nil?
  merged_dev = deep_merge(common, dev)
  ns = merged_dev.dig("__meta__", "catalog", "namespace")
  if ns == "babylon-catalog-dev"
    ok("merged DEV → babylon-catalog-dev")
  else
    err("merged DEV catalog.namespace must be babylon-catalog-dev, got #{ns.inspect}")
  end
  if merged_dev.dig("__meta__", "asset_uuid") == uuid
    ok("merged DEV retains asset_uuid")
  else
    err("merged DEV lost __meta__.asset_uuid from common.yaml")
  end
end

unless prod.nil?
  merged_prod = deep_merge(common, prod)
  catalog_id = merged_prod.dig("catalog_item", "id")
  if catalog_id == "published.lightwell-tssc-workshop.prod"
    ok("merged PROD catalog identity OK")
  else
    err("merged PROD catalog_item.id must be published.lightwell-tssc-workshop.prod, got #{catalog_id.inspect}")
  end
  if merged_prod.dig("__meta__", "asset_uuid") == uuid
    ok("merged PROD retains asset_uuid")
  else
    err("merged PROD lost __meta__.asset_uuid from common.yaml")
  end
end

agnosticv = ENV.fetch("AGNOSTICV_BIN", "agnosticv")
schema = root / "agnosticv" / ".schemas" / "babylon.yaml"
if system("command -v #{agnosticv} >/dev/null 2>&1") && schema.file?
  %w[dev.yaml prod.yaml].each do |stage|
    leaf_file = leaf / stage
    out = `#{agnosticv} --root #{root / 'agnosticv'} --merge #{leaf_file} 2>&1`
    if $?.success?
      ok("agnosticv --merge #{stage} OK")
    else
      err("agnosticv --merge #{stage} failed: #{out.strip}")
    end
  end
else
  ok("skip agnosticv CLI merge (install agnosticv + place babylon.yaml under agnosticv/.schemas/ for full schema)")
end

exit $failed
RUBY

exit "${failed}"
