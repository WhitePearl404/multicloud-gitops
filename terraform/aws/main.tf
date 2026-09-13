module "eks" {
  source = "../modules/eks"

  cluster_name    = var.cluster_name
  cluster_version = var.k8s_version
  vpc_id          = var.vpc_id
  subnet_ids      = var.subnet_ids

  node_groups = var.node_groups
}

module "argocd" {
  source = "../modules/argocd"

  # These module inputs assume the EKS module exposes these outputs.
  cluster_endpoint       = module.eks.endpoint
  cluster_ca_certificate = module.eks.cluster_ca_certificate
  cluster_name           = module.eks.cluster_name

  helm_values = yamlencode({
    configs = {
      params = {
        "server.insecure" = true
      }
    }
  })
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "argocd_namespace" {
  value = "argocd"
}
