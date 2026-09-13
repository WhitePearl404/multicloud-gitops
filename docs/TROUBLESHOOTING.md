# Troubleshooting

## Application is OutOfSync

```bash
kubectl -n argocd get applications
kubectl -n argocd describe application <name>
```

Check the source revision, path, destination namespace, and generated
ApplicationSet parameters.

## ApplicationSet generates no Applications

Confirm the cluster labels match the generator selector:

```bash
kubectl -n argocd get applicationset <name> -o yaml
kubectl -n argocd get secrets -l argocd.argoproj.io/secret-type=cluster
```

## Workload is Pending

Inspect scheduling events and resource quotas:

```bash
kubectl -n workloads get events --sort-by=.lastTimestamp
kubectl -n workloads describe resourcequota workloads-quota
```

## Local validation fails

Use `terraform validate`, `kubectl kustomize`, and YAML parsing only. Do not
switch to cloud credentials to debug a local rendering problem.
