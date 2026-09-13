# Architecture Decision

## Decision

This repository currently implements the multi-cluster model with two independent ArgoCD instances:

- one ArgoCD installation in the AWS EKS cluster
- one ArgoCD installation in the GCP GKE cluster
- each cluster has its own root Application and its own environment-specific ApplicationSets
- the GitOps manifests remain shared, but each cluster is bootstrapped independently

This is the default architecture for the repo today because it is easier to reason about, less sensitive to cross-cloud secret leakage, and safer during staged adoption.

## Why this model is the current default

The two-independent-ArgoCD model gives us:

- clear separation of responsibility between AWS and GCP clusters
- lower bootstrap risk during testing and onboarding
- no shared cross-cloud control-plane credentials during the initial implementation
- simpler cluster-specific RBAC and secret boundaries

It is a practical and research-aligned GitOps foundation for multi-cloud operations without forcing a single central control plane too early.

## Trade-off against the single-control-plane model

### Option A: Two independent ArgoCD instances (implemented)

Pros:
- simpler to bootstrap and debug
- no need to distribute cluster credentials across clouds
- easier to isolate failures to one environment or cloud
- lower secret-management complexity during early adoption

Cons:
- two control planes to operate and observe
- no single place to see all clusters in one ArgoCD UI
- slightly more duplication in bootstrap and RBAC setup

### Option B: One ArgoCD control plane for both clusters (next phase)

Pros:
- true single control plane for all clusters
- easier global visibility and policy enforcement
- a more canonical “multi-cloud GitOps” posture for large fleets

Cons:
- requires cluster credential management and secure registration of external clusters
- cross-cloud secret handling becomes part of the architecture, not an afterthought
- higher operational and security complexity

## Roadmap

### Phase 1: Current state (implemented)

- separate Terraform roots for AWS and GCP
- separate ArgoCD installations per cluster
- per-environment, per-cloud ApplicationSets
- shared GitOps application sources with cloud-specific values

### Phase 2: Single-control-plane evolution (next phase)

Planned work:

1. choose one cluster to host ArgoCD
2. add the second cluster as an external target via `argocd cluster add` or equivalent cluster secret registration
3. move to a cluster generator model so one template fans out to both clouds
4. define explicit app-placement policy: active-active, active-passive, or split-by-service
5. add external secret integration for AWS Secrets Manager and GCP Secret Manager
6. document cluster-specific RBAC and security review for the external cluster secret

## Recommendation

For this repo today, the two-independent-ArgoCD model is the correct choice. It gives us a robust multi-cloud GitOps foundation without introducing the extra credential and security complexity of a single control plane prematurely.

The single-control-plane model remains the intended evolution path once the cross-cloud secret and cluster registration patterns are fully designed and validated.
