data "aws_iam_policy_document" "gha_deploy_trust" {
  statement {
    sid     = "GitHubOidcAssume"
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = [local.oidc_audience]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:repository"
      values   = ["${var.github_owner}/${var.github_repo}"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:repository_owner"
      values   = [var.github_owner]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = local.github_oidc_subs
    }
  }
}

data "aws_iam_policy_document" "gha_deploy_permissions" {
  statement {
    sid = "IamReadPrefix"
    actions = [
      "iam:GetRole",
      "iam:GetRolePolicy",
      "iam:ListRolePolicies",
      "iam:ListAttachedRolePolicies",
      "iam:ListInstanceProfilesForRole",
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:ListPolicyVersions",
      "iam:ListEntitiesForPolicy",
    ]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.name_prefix}-*",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${local.name_prefix}-*",
    ]
  }

  statement {
    sid       = "IamListAccount"
    actions   = ["iam:ListRoles", "iam:ListPolicies"]
    resources = ["*"]
  }

  statement {
    sid = "IamManageIdentityRoles"
    actions = [
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:UpdateAssumeRolePolicy",
      "iam:UpdateRole",
      "iam:TagRole",
      "iam:UntagRole",
      "iam:AttachRolePolicy",
      "iam:DetachRolePolicy",
      "iam:PutRolePolicy",
      "iam:DeleteRolePolicy",
    ]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.name_prefix}-*",
    ]
  }

  statement {
    sid = "IamManageIdentityPolicies"
    actions = [
      "iam:CreatePolicy",
      "iam:DeletePolicy",
      "iam:CreatePolicyVersion",
      "iam:DeletePolicyVersion",
      "iam:SetDefaultPolicyVersion",
      "iam:TagPolicy",
      "iam:UntagPolicy",
    ]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${local.name_prefix}-*",
    ]
  }

  statement {
    sid = "StateBucketList"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketVersioning",
      "s3:GetBucketLocation",
    ]
    resources = [aws_s3_bucket.state.arn]
  }

  statement {
    sid = "StateBucketObjects"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:DeleteObjectVersion",
    ]
    resources = ["${aws_s3_bucket.state.arn}/*"]
  }

  statement {
    sid = "StateLockTable"
    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
      "dynamodb:Query",
    ]
    resources = [aws_dynamodb_table.lock.arn]
  }
}

resource "aws_iam_role" "gha_deploy" {
  name               = local.deploy_role_name
  assume_role_policy = data.aws_iam_policy_document.gha_deploy_trust.json
  tags               = local.tags

  lifecycle {
    precondition {
      condition     = local.github_environment == var.environment
      error_message = "github_environment deve ser igual a environment desta conta."
    }
  }
}

resource "aws_iam_policy" "gha_deploy" {
  name   = local.deploy_policy_name
  policy = data.aws_iam_policy_document.gha_deploy_permissions.json
  tags   = local.tags
}

resource "aws_iam_role_policy_attachment" "gha_deploy" {
  role       = aws_iam_role.gha_deploy.name
  policy_arn = aws_iam_policy.gha_deploy.arn
}
