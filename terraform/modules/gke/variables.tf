variable "project_id" {
  description = "GCP project that owns the cluster and network"
  type        = string
}

variable "region" {
  description = "GCP region used for the subnetwork"
  type        = string
}

variable "location" {
  description = "GKE location; use a region for a regional cluster"
  type        = string
}

variable "name" {
  description = "GKE cluster name"
  type        = string
}

variable "min_version" {
  description = "Minimum Kubernetes control-plane version"
  type        = string
}

variable "subnetwork_cidr" {
  description = "Primary IPv4 range for the cluster subnetwork"
  type        = string
  default     = "10.20.0.0/16"
}

variable "enable_network_policy" {
  description = "Enable Calico network policy enforcement"
  type        = bool
  default     = true
}

variable "release_channel" {
  description = "GKE release channel"
  type        = string
  default     = "REGULAR"

  validation {
    condition     = contains(["RAPID", "REGULAR", "STABLE"], var.release_channel)
    error_message = "release_channel must be RAPID, REGULAR, or STABLE."
  }
}

variable "deletion_protection" {
  description = "Prevent accidental cluster deletion"
  type        = bool
  default     = true
}

variable "environment" {
  description = "Environment label applied to node pools"
  type        = string
  default     = "dev"
}

variable "node_pools" {
  description = "GKE node pools to create"
  type = list(object({
    name          = string
    machine_type  = string
    min_count     = number
    max_count     = number
    initial_count = number
    disk_size_gb  = optional(number, 50)
  }))

  validation {
    condition     = length(var.node_pools) > 0
    error_message = "At least one GKE node pool must be configured."
  }
}

variable "workload_identity_roles" {
  description = "Project roles granted to the module's Workload Identity service account"
  type        = list(string)
  default     = []
}
