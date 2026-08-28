module "gke" {
  source = "../../../modules/gke"

  project_id  = var.project_id
  region      = var.region
  location    = var.location
  name        = var.cluster_name
  min_version = var.k8s_version
  environment = "dev"

  node_pools = var.node_pools
}

module "argocd" {
  source = "../../../modules/argocd"

  providers = {
    kubernetes.gke = kubernetes.gke
    helm.gke       = helm.gke
    kubectl.gke    = kubectl.gke
  }

  depends_on = [module.gke]

  argocd_namespace       = var.argocd_namespace
  argocd_chart_version   = var.argocd_chart_version
  git_repo_url           = var.git_repo_url
  git_target_revision    = var.git_target_revision
  root_app_path          = "gitops"
  root_app_include       = "clusters/dev-gcp.yaml"
  root_app_manifest_path = "${path.root}/../../../../gitops/root-app-of-apps.yaml"
  cluster_name           = module.gke.name
}

output "cluster_name" {
  value = module.gke.name
}

output "cluster_endpoint" {
  value = module.gke.cluster_endpoint
}
