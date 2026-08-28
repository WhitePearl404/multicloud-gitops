variable "project_id" { type = string }
variable "region" { type = string }
variable "location" { type = string }
variable "cluster_name" {
  type = string
  default = "prod-gcp"
}
variable "k8s_version" {
  type = string
  default = "1.29"
}
variable "argocd_namespace" {
  type = string
  default = "argocd"
}
variable "argocd_chart_version" {
  type = string
  default = "7.6.12"
}
variable "git_repo_url" { type = string }
variable "git_target_revision" {
  type = string
  default = "main"
}
variable "node_pools" {
  type = list(object({
    name = string
    machine_type = string
    min_count = number
    max_count = number
    initial_count = number
    disk_size_gb = optional(number, 80)
  }))
  default = [{
    name = "general"
    machine_type = "e2-standard-4"
    min_count = 2
    max_count = 6
    initial_count = 3
    disk_size_gb = 80
  }]
}
