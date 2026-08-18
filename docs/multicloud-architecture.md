Multicloud GitOps Architecture

Overview

This repo contains Terraform + GitOps manifests to run workloads across AWS (EKS) and GCP (GKE) using ArgoCD as the control plane in each cluster. Key patterns:

- Single Git repo is the single source of truth
- Terraform provisions EKS/GKE clusters and installs ArgoCD via a local module
- ArgoCD App-of-Apps (root application) boots child Applications and ApplicationSets
- ApplicationSets are used to drive the same apps to multiple clusters

Useful commands

- Create branch and push:
  git checkout -b gitops/multicloud-setup
  git add . && git commit -m "Add multicloud examples: terraform/aws, terraform/gcp, gitops/clusters" && git push -u origin gitops/multicloud-setup

Notes

- Replace ${git_repo_url} and ${git_target_revision} placeholders with your repo URL and branch/tag when templating via Terraform.
- The terraform modules in terraform/modules are reused by the example entrypoints under terraform/aws and terraform/gcp.
