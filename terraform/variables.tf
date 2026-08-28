##############################################
# General
##############################################

variable "aws_region" {
  description = "AWS region to deploy the EKS cluster into"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment label (e.g. dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "Common tags applied to every AWS resource"
  type        = map(string)
  default = {
    Project   = "multicloud-gitops"
    ManagedBy = "terraform"
  }
}

##############################################
# EKS / networking
##############################################

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "gitops-eks-cluster"
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS control plane"
  type        = string
  default     = "1.29"
}

variable "vpc_cidr" {
  description = "CIDR block for the cluster VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets (worker nodes)"
  type        = list(string)
  default     = ["10.0.0.0/20", "10.0.16.0/20", "10.0.32.0/20"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (NAT gateways / load balancers)"
  type        = list(string)
  default     = ["10.0.128.0/20", "10.0.144.0/20", "10.0.160.0/20"]
}

variable "node_instance_types" {
  description = "EC2 instance types for the managed node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 3
}

variable "node_min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 6
}

variable "node_disk_size" {
  description = "Root EBS volume size (GiB) for each worker node"
  type        = number
  default     = 50
}

##############################################
# ArgoCD / GitOps bootstrap
##############################################

variable "argocd_namespace" {
  description = "Kubernetes namespace ArgoCD is installed into"
  type        = string
  default     = "argocd"
}

variable "argocd_chart_version" {
  description = "Version of the argo-helm/argo-cd Helm chart to install"
  type        = string
  default     = "7.6.12"
}

variable "git_repo_url" {
  description = "URL of this Git repository, as ArgoCD will clone it (fork this repo and update the value)"
  type        = string
}

variable "git_target_revision" {
  description = "Git branch, tag, or commit ArgoCD tracks for the root Application"
  type        = string
  default     = "main"
}

variable "root_app_path" {
  description = "Path inside the Git repository the root Application recurses over. 'gitops' picks up gitops/apps/*, gitops/infrastructure/*, AND the root app manifest itself (deliberate self-management, a standard App-of-Apps idiom)."
  type        = string
  default     = "gitops"
}

variable "root_app_include" {
  description = "ApplicationSet manifest selected by this cluster's ArgoCD root app"
  type        = string
  default     = "clusters/prod-aws.yaml"
}
