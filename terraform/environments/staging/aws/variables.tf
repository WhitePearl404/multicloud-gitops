variable "aws_region" { type = string }
variable "environment" {
  type    = string
  default = "staging"
}
variable "cluster_name" {
  type    = string
  default = "staging-aws"
}
variable "cluster_version" {
  type    = string
  default = "1.29"
}
variable "vpc_cidr" {
  type    = string
  default = "10.30.0.0/16"
}
variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.30.0.0/20", "10.30.16.0/20", "10.30.32.0/20"]
}
variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.30.128.0/20", "10.30.144.0/20", "10.30.160.0/20"]
}
variable "node_instance_types" {
  type    = list(string)
  default = ["t3.medium"]
}
variable "node_desired_size" {
  type    = number
  default = 2
}
variable "node_min_size" {
  type    = number
  default = 1
}
variable "node_max_size" {
  type    = number
  default = 4
}
variable "node_disk_size" {
  type    = number
  default = 40
}
variable "argocd_namespace" {
  type    = string
  default = "argocd"
}
variable "argocd_chart_version" {
  type    = string
  default = "7.6.12"
}
variable "git_repo_url" { type = string }
variable "git_target_revision" {
  type    = string
  default = "main"
}
variable "tags" {
  type = map(string)
  default = {
    Project     = "multicloud-gitops"
    Environment = "staging"
    ManagedBy   = "terraform"
  }
}
