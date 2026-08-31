project_prefix = "datamesh-poc"
environment    = "dev"
aws_region     = "sa-east-1"

sor_bucket            = "datamesh-poc-dev-sor"
sot_bucket            = "datamesh-poc-dev-sot"
spec_bucket           = "datamesh-poc-dev-spec"
athena_results_bucket = "datamesh-poc-dev-athena-results"
athena_workgroup      = "datamesh-poc-dev"

analytics_principal_arns = [
  "arn:aws:iam::082846230365:user/yasmin-eng",
]
