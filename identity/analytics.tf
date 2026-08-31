check "analytics_principals_same_account" {
  assert {
    condition = alltrue([
      for arn in var.analytics_principal_arns :
      split(":", arn)[4] == data.aws_caller_identity.current.account_id
    ])
    error_message = "Todos os analytics_principal_arns devem ser da conta AWS atual."
  }
}

data "aws_iam_policy_document" "analytics_trust" {
  statement {
    sid     = "ListedPrincipalsAssume"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = var.analytics_principal_arns
    }
  }
}

data "aws_iam_policy_document" "analytics_permissions" {
  statement {
    sid = "LayerBucketsList"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
    ]
    resources = local.layer_bucket_arns
  }

  statement {
    sid       = "LayerObjectsRead"
    actions   = ["s3:GetObject"]
    resources = local.layer_object_arns
  }

  statement {
    sid = "AthenaResultsBucket"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
    ]
    resources = [local.athena_results_bucket_arn]
  }

  statement {
    sid = "AthenaResultsObjects"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:AbortMultipartUpload",
      "s3:ListMultipartUploadParts",
    ]
    resources = [local.athena_results_object_arn]
  }

  statement {
    sid = "GlueCatalogReadOnly"
    actions = [
      "glue:GetDatabase",
      "glue:GetDatabases",
      "glue:GetTable",
      "glue:GetTables",
      "glue:GetPartition",
      "glue:GetPartitions",
      "glue:BatchGetPartition",
    ]
    resources = local.glue_catalog_arns
  }

  statement {
    sid = "AthenaWorkgroup"
    actions = [
      "athena:StartQueryExecution",
      "athena:StopQueryExecution",
      "athena:GetQueryExecution",
      "athena:GetQueryResults",
      "athena:GetWorkGroup",
      "athena:BatchGetQueryExecution",
    ]
    resources = [local.athena_workgroup_arn]
  }

  # lakeformation:GetDataAccess is not scopable to S3/table ARNs (AWS API).
  statement {
    sid       = "LakeFormationGetDataAccess"
    actions   = ["lakeformation:GetDataAccess"]
    resources = ["*"]
  }
}

resource "aws_iam_role" "analytics" {
  name               = local.analytics_role_name
  assume_role_policy = data.aws_iam_policy_document.analytics_trust.json
  tags               = local.tags
}

resource "aws_iam_policy" "analytics" {
  name   = "${local.analytics_role_name}-policy"
  policy = data.aws_iam_policy_document.analytics_permissions.json
  tags   = local.tags
}

resource "aws_iam_role_policy_attachment" "analytics" {
  role       = aws_iam_role.analytics.name
  policy_arn = aws_iam_policy.analytics.arn
}
