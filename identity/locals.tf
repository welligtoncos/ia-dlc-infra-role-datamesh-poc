locals {
  name_prefix         = "${var.project_prefix}-${var.environment}"
  glue_role_name      = "${local.name_prefix}-glue-role"
  analytics_role_name = "${local.name_prefix}-analytics-role"

  layer_buckets = [
    var.sor_bucket,
    var.sot_bucket,
    var.spec_bucket,
  ]

  layer_bucket_arns = [for b in local.layer_buckets : "arn:aws:s3:::${b}"]
  layer_object_arns = [for b in local.layer_buckets : "arn:aws:s3:::${b}/*"]

  athena_results_bucket_arn = "arn:aws:s3:::${var.athena_results_bucket}"
  athena_results_object_arn = "arn:aws:s3:::${var.athena_results_bucket}/*"

  glue_log_arn = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws-glue/*"

  glue_catalog_arns = [
    "arn:aws:glue:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:catalog",
    "arn:aws:glue:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:database/*",
    "arn:aws:glue:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/*/*",
  ]

  athena_workgroup_arn = "arn:aws:athena:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:workgroup/${var.athena_workgroup}"

  tags = {
    Project        = var.project_prefix
    Environment    = var.environment
    ManagedBy      = "terraform"
    PipelineProbe  = "dev-2"
  }
}
