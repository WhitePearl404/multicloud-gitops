# Observability

The observability Application in `../infrastructure/observability.yaml` installs
`kube-prometheus-stack` in the cluster's `observability` namespace. Production
clusters should use the repository values in that Application and size the
components from measured workload and retention requirements.

## Local kind testing

The repository Application intentionally keeps Grafana, Alertmanager,
kube-state-metrics, and node-exporter enabled. That is appropriate for a real
cluster but is too large for the single-node `gitops-local` kind cluster.

For a disposable local test only, patch the live ArgoCD Application with a
small values document:

```bash
kubectl --context kind-gitops-local -n argocd patch application kube-prometheus-stack \
  --type merge -p '{"spec":{"source":{"helm":{"values":"grafana:\n  enabled: false\nalertmanager:\n  enabled: false\nkubeStateMetrics:\n  enabled: false\nprometheus-node-exporter:\n  enabled: false\nprometheus:\n  prometheusSpec:\n    replicas: 1\n    retention: 1d\n    resources:\n      requests:\n        cpu: 50m\n        memory: 128Mi\n      limits:\n        cpu: 250m\n        memory: 256Mi\n"}}}}'
```

This is a cluster-local override; it must not be committed as the production
Application configuration. A local chart can still remain Pending when the
kind node is already hosting ArgoCD and application workloads. In that case,
stop reconciliation, remove the `observability` namespace, and recreate the
kind cluster only when it is disposable:

```bash
kubectl --context kind-gitops-local -n argocd \
  annotate application kube-prometheus-stack argocd.argoproj.io/skip-reconcile=true \
  --overwrite
kubectl --context kind-gitops-local delete namespace observability --ignore-not-found
```

Do not run Terraform, `helm install`, or cloud provider commands for this
check. The local test validates manifest generation and Kubernetes admission;
it does not validate cloud metrics integrations.
