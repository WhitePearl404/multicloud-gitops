module "gke" {
  source = "../modules/gke"

  project_id  = var.project_id
  location    = var.location
  name        = var.cluster_name
  min_version = var.k8s_version

  node_pools = var.node_pools
}

module "argocd" {
  source = "../modules/argocd"

  cluster_endpoint       = module.gke.endpoint
  cluster_ca_certificate = base64decode(module.gke.master_auth[0].cluster_ca_certificate)
  cluster_name           = module.gke.name

  helm_values = yamlencode({
    configs = {
      params = {
        "server.insecure" = true
      }
    }
  })
}

output "gke_cluster_name" {
  value = module.gke.name
}
