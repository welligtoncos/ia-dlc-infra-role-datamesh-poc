# Copy the matching env/*.tfvars to terraform.tfvars (gitignored) inside identity/ for local apply.
# Do not commit real ARNs in this example; prefer env/dev.tfvars as the source.

project_prefix = "datamesh-poc"
environment    = "dev"
aws_region     = "sa-east-1"

sor_bucket            = "REPLACE-datamesh-poc-dev-sor"
sot_bucket            = "REPLACE-datamesh-poc-dev-sot"
spec_bucket           = "REPLACE-datamesh-poc-dev-spec"
athena_results_bucket = "REPLACE-datamesh-poc-dev-athena-results"
athena_workgroup      = "REPLACE-datamesh-poc-dev"

analytics_principal_arns = [
  "arn:aws:iam::123456789012:user/REPLACE-analyst",
]
