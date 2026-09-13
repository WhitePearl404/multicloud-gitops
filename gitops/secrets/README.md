# Secret management templates

The workload contract is a Kubernetes Secret named `redis-credentials` with a
`redis-password` key. No secret value belongs in Git.

The templates in this directory are examples only and are not included by the
App-of-Apps root. Enable one only after installing External Secrets Operator,
creating the cloud identity binding, and reviewing the target account/project.

- AWS: use a `SecretStore` backed by AWS Secrets Manager or SSM.
- GCP: use a `SecretStore` backed by Google Secret Manager.

Keep provider credentials in workload identity bindings, never in Kubernetes
manifests.
