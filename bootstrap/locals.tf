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

  github_oidc_branch = var.environment == "prod" ? "main" : var.environment

  # Conta GitHub com IDs no claim sub (owner@id/repo@id:...). AWS exige sub ou
  # job_workflow_ref nao aberto a todos; repository sozinho e recusado.
  github_sub_prefix = "repo:${var.github_owner}@${var.github_owner_id}/${var.github_repo}@${var.github_repo_id}"

  github_oidc_subs = [
    "${local.github_sub_prefix}:environment:${local.github_environment}",
    "${local.github_sub_prefix}:environment:${local.github_environment}:*",
    "${local.github_sub_prefix}:ref:refs/heads/${local.github_oidc_branch}",
    "${local.github_sub_prefix}:ref:refs/heads/${local.github_oidc_branch}:*",
  ]

  tags = {
    Project     = var.project_prefix
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}
