data "aws_iam_policy_document" "glue_trust" {
  statement {
    sid     = "GlueAssume"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["glue.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

data "aws_iam_policy_document" "glue_permissions" {
  statement {
    sid = "LayerBucketsList"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:ListBucketMultipartUploads",
    ]
    resources = local.layer_bucket_arns
  }

  statement {
    sid = "LayerObjectsReadWriteNoDelete"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:AbortMultipartUpload",
      "s3:ListMultipartUploadParts",
    ]
    resources = local.layer_object_arns
  }

  statement {
    sid = "GlueCatalogReadAndPartitions"
    actions = [
      "glue:GetDatabase",
      "glue:GetDatabases",
      "glue:GetTable",
      "glue:GetTables",
      "glue:GetPartition",
      "glue:GetPartitions",
      "glue:BatchGetPartition",
      "glue:CreatePartition",
      "glue:BatchCreatePartition",
      "glue:UpdatePartition",
      "glue:BatchUpdatePartition",
    ]
    resources = local.glue_catalog_arns
  }

  # lakeformation:GetDataAccess is not scopable to S3/table ARNs (AWS API).
  statement {
    sid       = "LakeFormationGetDataAccess"
    actions   = ["lakeformation:GetDataAccess"]
    resources = ["*"]
  }

  # Log group may not exist yet; prefix /aws-glue/* is the execution path.
  statement {
    sid = "GlueJobLogs"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [local.glue_log_arn]
  }
}

resource "aws_iam_role" "glue" {
  name               = local.glue_role_name
  assume_role_policy = data.aws_iam_policy_document.glue_trust.json
  tags               = local.tags
}

resource "aws_iam_policy" "glue" {
  name   = "${local.glue_role_name}-policy"
  policy = data.aws_iam_policy_document.glue_permissions.json
  tags   = local.tags
}

resource "aws_iam_role_policy_attachment" "glue" {
  role       = aws_iam_role.glue.name
  policy_arn = aws_iam_policy.glue.arn
}
