# Showroom Manifests Update Specification

Update guide for syncing Showroom components with upstream sources.

## Upstream Sources

| Source | Repository | Purpose |
|--------|------------|---------|
| **Ansible Collection** | https://github.com/agnosticd/agnosticd-v2 → `showroom/` | Role defaults, deployment logic |
| **Helm Chart** | https://github.com/rhpds/showroom-deployer | `showroom-single-pod` chart |

## Quick Reference: Current Versions

Check upstream at: `~/devel/git/agDv2/showroom/roles/ocp4_workload_showroom/defaults/main.yaml`

| Component | Variable | Current |
|-----------|----------|---------|
| Content image | `showroom_content_image` | `quay.io/rhpds/showroom-content:v1.3.1` |
| Terminal image | `showroom_terminal_image` | `quay.io/rhpds/openshift-showroom-terminal-ocp:latest` |
| Chart version | `showroom_deployer_chart_version` | `^2.0.0` |

## Files to Update

### Ansible Example

| File | What to Update |
|------|----------------|
| `examples/ansible/playbooks/roles/deploy-showroom/defaults/main.yml` | Image versions, chart version |
| `examples/ansible/playbooks/roles/deploy-showroom/tasks/main.yml` | Helm values structure (if changed) |

### Helm Example

| File | What to Update |
|------|----------------|
| `examples/helm/values.yaml` | Image versions in `showroom.*` section |
| `examples/helm/templates/showroom.yaml` | Pod spec, init containers (if structure changes) |

### Production chart (workshop)

| File | What to Update |
|------|----------------|
| `charts/components/showroom/values.yaml` | Content / terminal / nginx image pins (`showroom.content.image`, `showroom.terminal.image`, …) |
| `charts/root-app/values.yaml` | `components.showroom.content.image` / `terminal.image` (passed into the Application) |
| `charts/components/showroom/templates/showroom.yaml` | Pod spec if upstream single-pod layout changes |

## Update Procedure

### 1. Check Upstream Defaults

```bash
# Compare upstream with our ansible role
diff ~/devel/git/agDv2/showroom/roles/ocp4_workload_showroom/defaults/main.yaml \
     ~/devel/field-content/examples/ansible/playbooks/roles/deploy-showroom/defaults/main.yml
```

### 2. Update Image Versions

Key variables to sync from upstream `defaults/main.yaml`:

```yaml
# In ansible example: examples/ansible/playbooks/roles/deploy-showroom/defaults/main.yml
showroom_content_image: quay.io/rhpds/showroom-content:vX.X.X
showroom_terminal_image: quay.io/rhpds/openshift-showroom-terminal-ocp:latest

# In helm example: examples/helm/values.yaml
showroom:
  content:
    image: "quay.io/rhpds/showroom-content:vX.X.X"
```

### 3. Check Helm Values Structure

If upstream `tasks/deploy_showroom.yaml` changes the `release_values` structure, update:
- `examples/ansible/playbooks/roles/deploy-showroom/tasks/main.yml`

### 4. Test Deployment

```bash
# Deploy field-content helm example
oc apply -f - <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: showroom-test
  namespace: openshift-gitops
spec:
  project: default
  source:
    repoURL: https://github.com/rhpds/field-sourced-content-template
    path: examples/helm
    helm:
      parameters:
        - name: deployer.domain
          value: "apps.YOUR-CLUSTER.example.com"
  destination:
    server: https://kubernetes.default.svc
  syncPolicy:
    automated: {}
EOF
```

### 5. Verify

Local / CI contract (does not need a cluster):

```bash
./scripts/showroom-check.sh   # values + helm render + Modules 1–5 sources
./scripts/asciidoc-check.sh
npx antora@3.1.10 site-ci.yml # CI also asserts www/modules/module-0{1..5}-*.html
```

On cluster:

- [ ] Showroom pod running (3/3 containers ready)
- [ ] Route accessible, lab guide displays
- [ ] Terminal functional

## What NOT to Update

These upstream features are intentionally unsupported:

- Multi-user deployments (only single-user mode)
- Wetty terminal (only showroom terminal proxied at `/terminal/`)
- noVNC client
- LlamaStack / zero-touch *automation* playbooks (solve/validate runners)
- agnosticd.core integration (user data passed directly)

**Supported for this workshop:** repo-root [`ui-config.yml`](../ui-config.yml) plus the nookbag **ZT UI shell** (`nookbag.enabled: true`, bundle `nookbag-v0.4.0+`) so Showroom renders split-screen lab guide + Terminal tab. **RHTPA** embeds (`external: false`); **SSO Account Console / Nexus / OpenShift Console** use `external: true` because they set `X-Frame-Options`. SSO must target `/realms/tpa/account/` — bare `/realms/tpa` returns realm JSON, not a login page.
