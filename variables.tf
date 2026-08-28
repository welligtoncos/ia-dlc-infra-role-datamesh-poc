variable "project_prefix" {
  type        = string
  description = "Prefixo de nomes (contrato com o Projeto 2)."
  default     = "datamesh-poc"
}

variable "environment" {
  type        = string
  description = "Ambiente unico desta POC."
  default     = "dev"
}

variable "aws_region" {
  type        = string
  description = "Regiao AWS."
  default     = "sa-east-1"
}

variable "sor_bucket" {
  type        = string
  description = "Nome do bucket da camada SOR (nao criado aqui)."
}

variable "sot_bucket" {
  type        = string
  description = "Nome do bucket da camada SOT (nao criado aqui)."
}

variable "spec_bucket" {
  type        = string
  description = "Nome do bucket da camada SPEC (nao criado aqui)."
}

variable "athena_results_bucket" {
  type        = string
  description = "Nome do bucket de resultados Athena (nao criado aqui)."
}

variable "athena_workgroup" {
  type        = string
  description = "Nome do workgroup Athena (nao criado aqui)."
}

variable "analytics_principal_arns" {
  type        = list(string)
  description = "ARNs IAM (user ou role) da mesma conta que podem assumir a role Analytics."

  validation {
    condition     = length(var.analytics_principal_arns) > 0
    error_message = "analytics_principal_arns nao pode ser vazia."
  }

  validation {
    condition = alltrue([
      for arn in var.analytics_principal_arns :
      can(regex("^arn:aws:iam::[0-9]{12}:(user|role)/.+", arn))
    ])
    error_message = "Cada item deve ser ARN de iam user ou role (arn:aws:iam::ACCOUNT:user/|role/...)."
  }
}
