# Environment Promotion

Promotion is a Git change, not a direct cluster operation.

1. Develop and render the relevant `dev` overlay.
2. Open a pull request with application, policy, or infrastructure changes.
3. CI validates YAML, Kustomize, Terraform, and security checks.
4. Merge after review.
5. Promote the same version or image digest into `staging`.
6. Run smoke tests and review ArgoCD health.
7. Promote the approved version into `prod`.

Use immutable image digests for production promotion. Avoid changing
environment values and application code in the same unreviewed change.
