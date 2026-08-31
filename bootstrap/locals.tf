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

  # Repos novos (jul/2026): sub = repo:owner@ownerID/repo@repoID:contexto
  # :* cobre environment:dev, ref:heads/dev e job_workflow_ref do reusable.
  github_sub_prefix = "repo:${var.github_owner}@${var.github_owner_id}/${var.github_repo}@${var.github_repo_id}"

  github_oidc_subs = [
    "${local.github_sub_prefix}:*",
  ]

  tags = {
    Project     = var.project_prefix
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}
