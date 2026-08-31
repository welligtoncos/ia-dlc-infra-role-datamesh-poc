variable "project_prefix" {
  type        = string
  description = "Prefixo de nomes (contrato com identidade e Projeto 2)."
  default     = "datamesh-poc"
}

variable "environment" {
  type        = string
  description = "Ambiente desta conta. Deve ser dev, hom ou prod."
  default     = "dev"

  validation {
    condition     = contains(["dev", "hom", "prod"], var.environment)
    error_message = "environment deve ser dev, hom ou prod."
  }
}

variable "aws_region" {
  type        = string
  description = "Regiao AWS."
  default     = "sa-east-1"
}

variable "github_owner" {
  type        = string
  description = "Dono do repositorio GitHub (org ou user) no claim OIDC sub."
}

variable "github_repo" {
  type        = string
  description = "Nome do repositorio GitHub no claim OIDC sub."
}

variable "github_owner_id" {
  type        = string
  description = "ID numerico do owner no sub OIDC (ex. welligtoncos@58040980). Settings → Actions ou o claim sub do token."
}

variable "github_repo_id" {
  type        = string
  description = "ID numerico do repositorio no sub OIDC (ex. repo@1349046965)."
}

variable "github_environment" {
  type        = string
  nullable    = true
  default     = null
  description = "GitHub Environment no claim sub. Null usa var.environment (Terraform nao permite default = outra var)."

  validation {
    condition     = var.github_environment == null || contains(["dev", "hom", "prod"], var.github_environment)
    error_message = "github_environment deve ser dev, hom, prod ou null."
  }
}

variable "state_bucket_name" {
  type        = string
  nullable    = true
  default     = null
  description = "Override do nome S3 se a convencao {prefix}-{env}-tfstate ja existir no mundo."
}

variable "lock_table_name" {
  type        = string
  nullable    = true
  default     = null
  description = "Override do nome da tabela DynamoDB de lock. Null usa {prefix}-{env}-tf-lock."
}
