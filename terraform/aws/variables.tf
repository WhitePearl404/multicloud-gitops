variable "cluster_name" { type = string }
variable "k8s_version" { type = string }
variable "vpc_id" { type = string }
variable "subnet_ids" { type = list(string) }

variable "node_groups" {
  type = list(object({
    name          = string
    instance_type = string
    min_size      = number
    max_size      = number
    desired_size  = number
  }))
}
