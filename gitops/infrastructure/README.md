Infrastructure applications are cluster-scoped and are reconciled by the
cluster-specific App-of-Apps root.

## Secrets contract

Workloads require a `workloads/redis-credentials` Secret with a
`redis-password` key. Do not commit that Secret in plaintext. For AWS and GCP,
install External Secrets Operator separately and create a provider-specific
`SecretStore` plus an `ExternalSecret` that materializes this same Secret
contract in each cluster.

The application manifests reference only the Kubernetes Secret name and key,
so workload configuration remains cloud-neutral.

## Redis state

Redis is deployed as a single-replica StatefulSet with a `ReadWriteOnce` PVC.
This avoids treating Redis as an active-active replicated Deployment. For
cross-cloud active-active data, use a managed Redis service or a replication
topology designed for multi-region operation.
