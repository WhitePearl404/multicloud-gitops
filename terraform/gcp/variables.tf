variable "project_id" { type = string }
variable "region" { type = string }
variable "location" { type = string }
variable "cluster_name" { type = string }
variable "k8s_version" { type = string }

variable "argocd_namespace" {
  type    = string
  default = "argocd"
}

variable "argocd_chart_version" {
  type    = string
  default = "7.6.12"
}

variable "git_repo_url" {
  type = string
}

variable "git_target_revision" {
  type    = string
  default = "main"
}

variable "root_app_path" {
  type    = string
  default = "gitops"
}

variable "node_pools" {
  type = list(object({
    name          = string
    machine_type  = string
    min_count     = number
    max_count     = number
    initial_count = number
  }))
}
