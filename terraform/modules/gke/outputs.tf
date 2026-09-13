output "name" {
  description = "Name of the GKE cluster"
  value       = google_container_cluster.this.name
}

output "cluster_name" {
  description = "Name of the GKE cluster"
  value       = google_container_cluster.this.name
}

output "endpoint" {
  description = "GKE API server hostname without a scheme"
  value       = google_container_cluster.this.endpoint
}

output "cluster_endpoint" {
  description = "GKE API server endpoint with HTTPS scheme"
  value       = "https://${google_container_cluster.this.endpoint}"
}

output "cluster_ca_certificate" {
  description = "Base64-encoded GKE cluster CA certificate"
  value       = google_container_cluster.this.master_auth[0].cluster_ca_certificate
  sensitive   = true
}

output "master_auth" {
  description = "GKE master authentication details"
  value       = google_container_cluster.this.master_auth
  sensitive   = true
}

output "network_name" {
  description = "Name of the VPC created for the cluster"
  value       = google_compute_network.this.name
}

output "subnetwork_name" {
  description = "Name of the subnetwork created for the cluster"
  value       = google_compute_subnetwork.this.name
}

output "workload_identity_service_account_email" {
  description = "Google service account available for Workload Identity bindings"
  value       = google_service_account.workload_identity.email
}
