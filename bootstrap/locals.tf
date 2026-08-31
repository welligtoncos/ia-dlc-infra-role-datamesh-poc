locals {
  name_prefix = "${var.project_prefix}-${var.environment}"

  state_bucket_name  = coalesce(var.state_bucket_name, "${local.name_prefix}-tfstate")
  lock_table_name    = coalesce(var.lock_table_name, "${local.name_prefix}-tf-lock")
  deploy_role_name   = "${local.name_prefix}-gha-deploy-role"
  deploy_policy_name = "${local.deploy_role_name}-policy"

  github_environment = coalesce(var.github_environment, var.environment)

  oidc_url = "https://token.actions.githubusercontent.com"

  # GitHub Actions OIDC thumbprints (AWS/GitHub documented; no tls provider).
  oidc_thumbprints = [
    "6938fd4d98bab03faadb97b34396831e3780aea3",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd",
  ]

  oidc_audience = "sts.amazonaws.com"

  github_sub = "repo:${var.github_owner}/${var.github_repo}:environment:${local.github_environment}"

  # Job plan (hom/prod) has no GitHub Environment; OIDC sub is ref of the caller branch.
  github_oidc_branch = var.environment == "prod" ? "main" : var.environment
  github_sub_ref     = "repo:${var.github_owner}/${var.github_repo}:ref:refs/heads/${local.github_oidc_branch}"

  # Reusable workflow (deploy-identity.yml): GitHub often sets sub to job_workflow_ref, or
  # appends extra claim segments. StringLike exact (no *) does not match those tokens.
  github_sub_job_workflow = "repo:${var.github_owner}/${var.github_repo}:job_workflow_ref:${var.github_owner}/${var.github_repo}/.github/workflows/deploy-identity.yml@*"

  github_oidc_subs = [
    local.github_sub,
    "${local.github_sub}:*",
    local.github_sub_ref,
    "${local.github_sub_ref}:*",
    local.github_sub_job_workflow,
    "repo:${var.github_owner}/${var.github_repo}:*",
    "job_workflow_ref:${var.github_owner}/${var.github_repo}/*",
  ]

  tags = {
    Project     = var.project_prefix
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}
