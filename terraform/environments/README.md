# Environment Terraform roots

The `dev/aws` and `dev/gcp` directories are separate Terraform roots. They
use local state by default and contain only example variables. No credentials
are stored in Git.

These roots are intended to be validated before any deployment. Do not run
`terraform apply` unless you explicitly intend to create cloud resources.

To validate without planning or applying:

```bash
terraform -chdir=terraform/environments/dev/aws init -backend=false
terraform -chdir=terraform/environments/dev/aws validate
terraform -chdir=terraform/environments/dev/gcp init -backend=false
terraform -chdir=terraform/environments/dev/gcp validate
```
