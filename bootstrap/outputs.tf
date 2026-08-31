output "state_bucket_name" {
  description = "Bucket S3 do backend remoto da identidade (U3)."
  value       = aws_s3_bucket.state.id
}

output "lock_table_name" {
  description = "Tabela DynamoDB de lock do backend da identidade (U3)."
  value       = aws_dynamodb_table.lock.name
}

output "deploy_role_arn" {
  description = "ARN da role assumida pelo GitHub Actions via OIDC."
  value       = aws_iam_role.gha_deploy.arn
}

output "oidc_provider_arn" {
  description = "ARN do OIDC provider GitHub nesta conta (diagnostico)."
  value       = aws_iam_openid_connect_provider.github.arn
}

output "aws_region" {
  description = "Regiao do backend e dos recursos."
  value       = var.aws_region
}
