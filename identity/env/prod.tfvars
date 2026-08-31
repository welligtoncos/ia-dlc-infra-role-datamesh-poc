# Placeholders — copy to terraform.tfvars (gitignored) for local apply.
# CI uses -var-file=env/prod.tfvars

project_prefix = "datamesh-poc"
environment    = "prod"
aws_region     = "sa-east-1"

sor_bucket            = "REPLACE-datamesh-poc-prod-sor"
sot_bucket            = "REPLACE-datamesh-poc-prod-sot"
spec_bucket           = "REPLACE-datamesh-poc-prod-spec"
athena_results_bucket = "REPLACE-datamesh-poc-prod-athena-results"
athena_workgroup      = "REPLACE-datamesh-poc-prod"

analytics_principal_arns = [
  "arn:aws:iam::123456789012:user/REPLACE-analyst",
]
