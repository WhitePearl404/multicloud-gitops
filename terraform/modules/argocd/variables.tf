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
  description = "URL of the Git repository ArgoCD watches for the App-of-Apps root application"
  type        = string
}

variable "git_target_revision" {
  description = "Git branch, tag, or commit ArgoCD tracks"
  type        = string
  default     = "main"
}

variable "root_app_path" {
  description = "Path inside the Git repository that the root Application recurses over (gitops/apps + gitops/infrastructure)"
  type        = string
  default     = "gitops"
}

variable "root_app_manifest_path" {
  description = "Local filesystem path to the root-app-of-apps.yaml template that Terraform renders and applies"
  type        = string
}

variable "cluster_name" {
  description = "Name of the target EKS cluster, used only for labeling the ArgoCD resources"
  type        = string
  default     = "eks-cluster"
}
