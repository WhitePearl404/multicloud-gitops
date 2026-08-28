##############################################
# Namespace
##############################################

resource "kubernetes_namespace" "argocd" {
  provider = kubernetes.gke

  metadata {
    name = var.argocd_namespace

    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
      "cluster"                      = var.cluster_name
    }
  }
}

##############################################
# ArgoCD - installed via the Terraform Helm provider
# This is the "dynamic bootstrap" step: no `helm install` command
# is ever run by hand.
##############################################

resource "helm_release" "argocd" {
  provider = helm.gke

  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.argocd_chart_version
  namespace        = kubernetes_namespace.argocd.metadata[0].name
  create_namespace = false
  wait             = true
  timeout          = 600
  atomic           = true

  values = [
    file("${path.module}/helm_values.yaml")
  ]

  depends_on = [kubernetes_namespace.argocd]
}

##############################################
# App-of-Apps bootstrap
#
# Terraform applies exactly ONE Application CRD: the "root" app.
# From this point on ArgoCD owns everything under gitops/apps/**
# and gitops/infrastructure/** -- no further `kubectl apply` is
# ever needed for day-2 application changes, satisfying the
# zero-manual-intervention / pure GitOps requirement.
##############################################

resource "kubectl_manifest" "root_app" {
  provider = kubectl.gke

  yaml_body = templatefile(var.root_app_manifest_path, {
    git_repo_url        = var.git_repo_url
    git_target_revision = var.git_target_revision
    root_app_path       = var.root_app_path
    argocd_namespace    = kubernetes_namespace.argocd.metadata[0].name
  })

  depends_on = [helm_release.argocd]
}
