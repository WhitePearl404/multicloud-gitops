##############################################
# Module: EKS cluster + networking
##############################################

module "eks" {
  source = "./modules/eks"

  cluster_name         = var.cluster_name
  cluster_version      = var.cluster_version
  vpc_cidr             = var.vpc_cidr
  private_subnet_cidrs = var.private_subnet_cidrs
  public_subnet_cidrs  = var.public_subnet_cidrs
  node_instance_types  = var.node_instance_types
  node_desired_size    = var.node_desired_size
  node_min_size        = var.node_min_size
  node_max_size        = var.node_max_size
  node_disk_size       = var.node_disk_size
  environment          = var.environment
  tags                 = var.tags
}

##############################################
# Module: ArgoCD bootstrap (App-of-Apps)
#
# Runs only after the EKS cluster + node group are ready, since
# the kubernetes/helm/kubectl providers (configured in providers.tf)
# need a live API server endpoint to talk to.
##############################################

module "argocd" {
  source = "./modules/argocd"

  providers = {
    kubernetes.gke = kubernetes
    helm.gke       = helm
    kubectl.gke    = kubectl
  }

  depends_on = [module.eks]

  argocd_namespace       = var.argocd_namespace
  argocd_chart_version   = var.argocd_chart_version
  git_repo_url           = var.git_repo_url
  git_target_revision    = var.git_target_revision
  root_app_path          = var.root_app_path
  root_app_include       = var.root_app_include
  root_app_manifest_path = "${path.root}/../gitops/root-app-of-apps.yaml"
  cluster_name           = module.eks.cluster_name
}
