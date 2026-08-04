terraform {
  required_version = ">= 1.6.0"

  # Remote state with a locked backend so two engineers (or two CI runs)
  # can never write state at the same time.
  #
  # Real values are supplied at `terraform init` time via a backend config
  # file so this stays environment-agnostic, e.g.:
  #   terraform init -backend-config=backend.hcl
  #
  # backend.hcl (per environment, NOT committed):
  #   bucket         = "my-org-terraform-state"
  #   key            = "multicloud-gitops/dev/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "terraform-state-locks"   # holds the state lock (LockID hash key)
  #   encrypt        = true
  backend "s3" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.50"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.31"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.14"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.tags
  }
}

# The kubernetes/helm/kubectl providers authenticate dynamically against
# the cluster this same `terraform apply` just created -- no static
# kubeconfig file and no manual `aws eks update-kubeconfig` step required
# for Terraform itself to talk to the cluster.
data "aws_eks_cluster_auth" "this" {
  name       = module.eks.cluster_name
  depends_on = [module.eks]
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_ca_certificate)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_ca_certificate)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

provider "kubectl" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_ca_certificate)
  token                  = data.aws_eks_cluster_auth.this.token
  load_config_file       = false
  apply_retry_count      = 5
}
