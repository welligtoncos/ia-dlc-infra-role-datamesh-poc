output "glue_role_arn" {
  description = "ARN da execution role Glue (Projeto 2)."
  value       = aws_iam_role.glue.arn
}

output "analytics_role_arn" {
  description = "ARN da role de Analytics (Projeto 2)."
  value       = aws_iam_role.analytics.arn
}

output "access_role_arn" {
  description = "Reservado ao contrato do Projeto 2. Sempre null nesta POC."
  value       = null
}
