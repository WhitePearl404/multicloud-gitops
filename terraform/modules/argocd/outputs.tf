output "namespace" {
  description = "Namespace ArgoCD was installed into"
  value       = kubernetes_namespace.argocd.metadata[0].name
}

output "helm_release_name" {
  description = "Name of the ArgoCD Helm release"
  value       = helm_release.argocd.name
}

output "helm_release_status" {
  description = "Status Terraform observed for the ArgoCD Helm release after apply"
  value       = helm_release.argocd.status
}

output "root_application_name" {
  description = "Name of the bootstrapped App-of-Apps root Application"
  value       = "root-app-of-apps"
}
