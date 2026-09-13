terraform {
  required_providers {
    kubernetes = {
      source                = "hashicorp/kubernetes"
      version               = ">= 2.31"
      configuration_aliases = [kubernetes.gke]
    }
    helm = {
      source                = "hashicorp/helm"
      version               = ">= 2.14"
      configuration_aliases = [helm.gke]
    }
    kubectl = {
      source                = "gavinbunney/kubectl"
      version               = ">= 1.14"
      configuration_aliases = [kubectl.gke]
    }
  }
}
