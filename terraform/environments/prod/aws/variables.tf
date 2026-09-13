variable "aws_region" { type = string }
variable "environment" {
  type = string
  default = "prod"
}
variable "cluster_name" {
  type = string
  default = "prod-aws"
}
variable "cluster_version" {
  type = string
  default = "1.29"
}
variable "vpc_cidr" {
  type = string
  default = "10.40.0.0/16"
}
variable "private_subnet_cidrs" {
  type = list(string)
  default = ["10.40.0.0/20", "10.40.16.0/20", "10.40.32.0/20"]
}
variable "public_subnet_cidrs" {
  type = list(string)
  default = ["10.40.128.0/20", "10.40.144.0/20", "10.40.160.0/20"]
}
variable "node_instance_types" {
  type = list(string)
  default = ["t3.large"]
}
variable "node_desired_size" {
  type = number
  default = 3
}
variable "node_min_size" {
  type = number
  default = 2
}
variable "node_max_size" {
  type = number
  default = 6
}
variable "node_disk_size" {
  type = number
  default = 80
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
variable "tags" {
  type = map(string)
  default = {
    Project = "multicloud-gitops"
    Environment = "prod"
    ManagedBy = "terraform"
  }
}
