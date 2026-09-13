#!/usr/bin/env bash
#
# Run repository validation without contacting AWS, GCP, or any remote
# Terraform backend. This script never creates Kubernetes clusters.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${REPO_ROOT}"

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    printf 'error: %s is required\n' "$1" >&2
    exit 1
  }
}

for cmd in ruby kubectl terraform; do
  require_cmd "${cmd}"
done

printf '%s\n' 'Validating GitOps YAML...'
ruby -e '
  require "yaml"
  files = Dir["gitops/clusters/*.yaml",
              "gitops/infrastructure/*.yaml",
              "gitops/policies/*.yaml",
              "gitops/platform/**/*.yaml",
              "gitops/secrets/*.yaml"].sort
  abort "no GitOps YAML files found" if files.empty?
  files.each do |file|
    YAML.load_stream(File.read(file))
    puts "YAML OK #{file}"
  end
'

printf '%s\n' 'Rendering Kustomize overlays...'
overlays=(
  gitops/apps/frontend/overlays/dev
  gitops/apps/frontend/overlays/staging
  gitops/apps/frontend/overlays/prod
  gitops/apps/backend/overlays/dev
  gitops/apps/backend/overlays/staging
  gitops/apps/backend/overlays/prod
  gitops/apps/redis/overlays/dev
  gitops/apps/redis/overlays/staging
  gitops/apps/redis/overlays/prod
  gitops/platform/workloads
)
for overlay in "${overlays[@]}"; do
  kubectl kustomize "${overlay}" >/dev/null
  printf 'Kustomize OK %s\n' "${overlay}"
done

printf '%s\n' 'Validating Terraform roots without backend initialization...'
roots=(
  terraform/environments/dev/aws
  terraform/environments/dev/gcp
  terraform/environments/staging/aws
  terraform/environments/staging/gcp
  terraform/environments/prod/aws
  terraform/environments/prod/gcp
)
for root in "${roots[@]}"; do
  terraform -chdir="${root}" validate >/dev/null
  printf 'Terraform OK %s\n' "${root}"
done

printf '%s\n' 'Local validation passed. No cloud command was executed.'
