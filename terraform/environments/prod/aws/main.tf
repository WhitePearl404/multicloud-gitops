module "eks" {
  source = "../../../modules/eks"
  cluster_name = var.cluster_name
  cluster_version = var.cluster_version
  vpc_cidr = var.vpc_cidr
  private_subnet_cidrs = var.private_subnet_cidrs
  public_subnet_cidrs = var.public_subnet_cidrs
  node_instance_types = var.node_instance_types
  node_desired_size = var.node_desired_size
  node_min_size = var.node_min_size
  node_max_size = var.node_max_size
  node_disk_size = var.node_disk_size
  environment = var.environment
  tags = var.tags
}

module "argocd" {
  source = "../../../modules/argocd"
  providers = {
    kubernetes.gke = kubernetes.eks
    helm.gke = helm.eks
    kubectl.gke = kubectl.eks
  }
  depends_on = [module.eks]
  argocd_namespace = var.argocd_namespace
  argocd_chart_version = var.argocd_chart_version
  git_repo_url = var.git_repo_url
  git_target_revision = var.git_target_revision
  root_app_path = "gitops"
  root_app_include = "{clusters/prod-aws.yaml,infrastructure/*.yaml,policies/*-application.yaml}"
  root_app_manifest_path = "${path.root}/../../../../gitops/root-app-of-apps.yaml"
  cluster_name = module.eks.cluster_name
}

output "cluster_name" { value = module.eks.cluster_name }
output "cluster_endpoint" { value = module.eks.cluster_endpoint }
