#!/usr/bin/env bash
#
# bootstrap.sh
#
# One command to go from an empty AWS account to a running EKS cluster
# with ArgoCD managing the whole workload tree via GitOps.
#
# Usage:
#   ./scripts/bootstrap.sh
#
# Optional environment variables:
#   AWS_REGION            (default: us-east-1)
#   TF_VAR_git_repo_url   (default: read from terraform.tfvars)
#   REDIS_PASSWORD        (default: auto-generated, printed once at the end)
#   SKIP_TERRAFORM_APPLY  (set to "true" to only re-run the post-checks)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
TF_DIR="${REPO_ROOT}/terraform"

AWS_REGION="${AWS_REGION:-us-east-1}"
SKIP_TERRAFORM_APPLY="${SKIP_TERRAFORM_APPLY:-false}"

log()  { printf '\n\033[1;34m[bootstrap]\033[0m %s\n' "$1"; }
die()  { printf '\n\033[1;31m[bootstrap][error]\033[0m %s\n' "$1" >&2; exit 1; }

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "'$1' is required but was not found on PATH."
}

##############################################
# 0. Pre-flight checks
##############################################

log "Checking required tools..."
for cmd in terraform aws kubectl; do
  require_cmd "$cmd"
done

if [[ ! -f "${TF_DIR}/terraform.tfvars" ]]; then
  die "Missing ${TF_DIR}/terraform.tfvars. Copy terraform.tfvars.example to terraform.tfvars and fill in your values first."
fi

##############################################
# 1. Terraform: provision VPC + EKS + ArgoCD
##############################################

if [[ "${SKIP_TERRAFORM_APPLY}" != "true" ]]; then
  log "Initializing Terraform (backend config lives outside this script -- see providers.tf)..."
  terraform -chdir="${TF_DIR}" init -upgrade

  log "Validating Terraform configuration..."
  terraform -chdir="${TF_DIR}" validate

  log "Planning and applying: this creates the VPC, EKS cluster, node group, and installs ArgoCD via Helm..."
  terraform -chdir="${TF_DIR}" apply -auto-approve
else
  log "SKIP_TERRAFORM_APPLY=true -- skipping terraform apply, running post-checks only."
fi

CLUSTER_NAME="$(terraform -chdir="${TF_DIR}" output -raw cluster_name)"
ARGOCD_NAMESPACE="$(terraform -chdir="${TF_DIR}" output -raw argocd_namespace)"

##############################################
# 2. Wire up kubectl against the new cluster
##############################################

log "Fetching cluster credentials for kubectl (cluster: ${CLUSTER_NAME}, region: ${AWS_REGION})..."
aws eks update-kubeconfig --region "${AWS_REGION}" --name "${CLUSTER_NAME}"

log "Waiting for node group to report Ready nodes..."
kubectl wait --for=condition=Ready nodes --all --timeout=300s

##############################################
# 3. Create the redis-credentials Secret
#
# Deliberately done here, not in Git -- see README "Secrets" section.
# Re-running this script is safe: it will not overwrite an existing secret.
##############################################

if kubectl -n workloads get secret redis-credentials >/dev/null 2>&1; then
  log "Secret 'redis-credentials' already exists in namespace 'workloads' -- leaving it untouched."
else
  log "Creating 'redis-credentials' Secret..."
  kubectl create namespace workloads --dry-run=client -o yaml | kubectl apply -f -

  GENERATED_PASSWORD="${REDIS_PASSWORD:-$(openssl rand -base64 24)}"
  kubectl -n workloads create secret generic redis-credentials \
    --from-literal=redis-password="${GENERATED_PASSWORD}"

  log "Redis password (save this now, it will not be printed again):"
  echo "  ${GENERATED_PASSWORD}"
fi

##############################################
# 4. Verify ArgoCD is up and the root app synced
##############################################

log "Waiting for the ArgoCD server Deployment to become available..."
kubectl -n "${ARGOCD_NAMESPACE}" rollout status deployment/argocd-server --timeout=300s

log "Checking sync + health status of the root Application (root-app-of-apps)..."
for i in {1..30}; do
  SYNC_STATUS="$(kubectl -n "${ARGOCD_NAMESPACE}" get application root-app-of-apps \
    -o jsonpath='{.status.sync.status}' 2>/dev/null || echo "Unknown")"
  HEALTH_STATUS="$(kubectl -n "${ARGOCD_NAMESPACE}" get application root-app-of-apps \
    -o jsonpath='{.status.health.status}' 2>/dev/null || echo "Unknown")"

  if [[ "${SYNC_STATUS}" == "Synced" && "${HEALTH_STATUS}" == "Healthy" ]]; then
    log "root-app-of-apps is Synced and Healthy."
    break
  fi

  log "Attempt ${i}/30: sync=${SYNC_STATUS} health=${HEALTH_STATUS} -- retrying in 10s..."
  sleep 10
done

if [[ "${SYNC_STATUS}" != "Synced" || "${HEALTH_STATUS}" != "Healthy" ]]; then
  die "root-app-of-apps did not become Synced/Healthy in time. Run: kubectl -n ${ARGOCD_NAMESPACE} get applications"
fi

log "Listing every Application ArgoCD is now managing:"
kubectl -n "${ARGOCD_NAMESPACE}" get applications

ADMIN_PASSWORD_CMD="kubectl -n ${ARGOCD_NAMESPACE} get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
log "Bootstrap complete. ArgoCD admin password: run -> ${ADMIN_PASSWORD_CMD}"
