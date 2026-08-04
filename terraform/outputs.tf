output "cluster_name" {
  description = "Name of the provisioned EKS cluster"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "API server endpoint of the EKS cluster"
  value       = module.eks.cluster_endpoint
}

output "cluster_version" {
  description = "Kubernetes version running on the control plane"
  value       = module.eks.cluster_version
}

output "vpc_id" {
  description = "ID of the VPC created for the cluster"
  value       = module.eks.vpc_id
}

output "oidc_provider_arn" {
  description = "ARN of the IAM OIDC provider (used when wiring IRSA roles for workloads)"
  value       = module.eks.oidc_provider_arn
}

output "configure_kubectl" {
  description = "Command to fetch cluster credentials for kubectl / kubeconfig"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}

output "argocd_namespace" {
  description = "Namespace ArgoCD was installed into"
  value       = var.argocd_namespace
}

output "argocd_initial_admin_secret_hint" {
  description = "How to retrieve the initial ArgoCD admin password after apply"
  value       = "kubectl -n ${var.argocd_namespace} get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
}
