# Environment Terraform roots

Each environment/cloud directory is a separate Terraform root:

```text
dev/aws      dev/gcp
staging/aws  staging/gcp
prod/aws     prod/gcp
```

They use local state by default and contain only example variables. No
credentials are stored in Git.

## Remote state

Before a real deployment, configure a separate remote state key for every
root. Do not share a state file between AWS and GCP or between environments.

AWS roots use an S3 backend with locking:

```text
bucket         = "your-terraform-state-bucket"
key            = "multicloud-gitops/<environment>/aws/terraform.tfstate"
region         = "us-east-1"
dynamodb_table = "your-terraform-state-locks"
encrypt        = true
```

GCP roots use a GCS backend with bucket-level locking:

```text
bucket = "your-terraform-state-bucket"
prefix = "multicloud-gitops/<environment>/gcp"
```

Store these values in untracked `backend.hcl` files or CI secret variables.
Never commit credentials or backend configuration containing sensitive
organization details.

These roots are intended to be validated before any deployment. Do not run
`terraform apply` unless you explicitly intend to create cloud resources.

To validate without planning or applying:

```bash
terraform -chdir=terraform/environments/dev/aws init -backend=false
terraform -chdir=terraform/environments/dev/aws validate
terraform -chdir=terraform/environments/dev/gcp init -backend=false
terraform -chdir=terraform/environments/dev/gcp validate
```

Do not use `terraform init -backend-config=backend.hcl` during local-only
testing; that intentionally connects to the configured state service.
