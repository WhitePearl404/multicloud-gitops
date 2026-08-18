variable "project_id" { type = string }
variable "location" { type = string }
variable "cluster_name" { type = string }
variable "k8s_version" { type = string }

variable "node_pools" {
  type = list(object({
    name          = string
    machine_type  = string
    min_count     = number
    max_count     = number
    initial_count = number
  }))
}
