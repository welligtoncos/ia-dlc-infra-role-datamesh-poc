# Placeholders — copy to terraform.tfvars (gitignored) for local apply.
# CI uses -var-file=env/hom.tfvars

project_prefix = "datamesh-poc"
environment    = "hom"
aws_region     = "sa-east-1"

sor_bucket            = "REPLACE-datamesh-poc-hom-sor"
sot_bucket            = "REPLACE-datamesh-poc-hom-sot"
spec_bucket           = "REPLACE-datamesh-poc-hom-spec"
athena_results_bucket = "REPLACE-datamesh-poc-hom-athena-results"
athena_workgroup      = "REPLACE-datamesh-poc-hom"

analytics_principal_arns = [
  "arn:aws:iam::123456789012:user/REPLACE-analyst",
]
