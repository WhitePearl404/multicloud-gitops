# Disaster Recovery Runbook

## Scope

This runbook covers restoring GitOps control and workloads after losing a
cluster. It does not replace provider-specific recovery plans or database
backup requirements.

## Recovery order

1. Preserve the last known-good Git commit and environment variables.
2. Restore the affected Terraform state from its isolated S3 or GCS backend.
3. Recreate only the affected EKS or GKE environment from its Terraform root.
4. Reconfigure kubeconfig and verify cluster identity before any ArgoCD action.
5. Install ArgoCD through the `modules/argocd` bootstrap.
6. Apply or allow ArgoCD to reconcile the root App-of-Apps.
7. Restore cloud-backed secrets through External Secrets or the approved
   encrypted-secret workflow.
8. Restore Redis data from a tested backup if Redis is used as durable state.
9. Verify Application sync, workload health, ingress, policies, and metrics.

## Validation checklist

- [ ] Correct cloud account/project and environment confirmed.
- [ ] Terraform state lock is healthy.
- [ ] Cluster endpoint and identity are expected.
- [ ] ArgoCD root Application is `Synced` and `Healthy`.
- [ ] ApplicationSets generate only the intended environment.
- [ ] Secret contract `redis-credentials/redis-password` is available.
- [ ] PVCs and backups are restored where required.
- [ ] Kyverno policies are enforcing expected controls.
- [ ] Ingress, probes, and observability are healthy.

## Local-only rehearsal

Use a disposable kind cluster and local Git mirror to rehearse manifest
rendering and ArgoCD bootstrap. Never point that rehearsal at a production Git
branch or cloud credentials.
