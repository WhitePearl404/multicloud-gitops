Policies

Place OPA/OPA Gatekeeper or Kyverno policies in this directory as code. Examples:
- kyverno-resource-limits.yaml — example Kyverno ClusterPolicy that enforces resource requests/limits.

Deployment:
- Install Kyverno (or Gatekeeper) in each cluster, then create the policies via ArgoCD (infrastructure or a dedicated policy-controller Application) so policies are kept in Git.
