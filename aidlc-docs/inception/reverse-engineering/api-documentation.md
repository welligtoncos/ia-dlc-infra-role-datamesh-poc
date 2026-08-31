# Documentação de API

Este repositório não expõe API HTTP. O contrato é Terraform variables/outputs e APIs AWS usadas no apply e nos testes.

## APIs REST

Nenhuma. Sem ALB, API Gateway, Lambda handlers ou OpenAPI.

## APIs Internas (contrato Terraform)

### Inputs (`variables.tf`)

| Variável | Tipo | Default | Papel |
|----------|------|---------|-------|
| `project_prefix` | string | `datamesh-poc` | Prefixo de nomes |
| `environment` | string | `dev` | Sufixo de ambiente nos nomes |
| `aws_region` | string | `sa-east-1` | Região do provider |
| `sor_bucket` | string | (obrigatório) | Nome bucket SOR (não cria) |
| `sot_bucket` | string | (obrigatório) | Nome bucket SOT |
| `spec_bucket` | string | (obrigatório) | Nome bucket SPEC |
| `athena_results_bucket` | string | (obrigatório) | Nome bucket resultados Athena |
| `athena_workgroup` | string | (obrigatório) | Nome workgroup Athena |
| `analytics_principal_arns` | list(string) | (obrigatório, len > 0) | ARNs IAM user/role que assumem Analytics; devem ser da mesma conta do apply |

Validação de ARN: regex `^arn:aws:iam::[0-9]{12}:(user|role)/.+`

### Outputs (`outputs.tf`)

| Output | Tipo | Papel |
|--------|------|-------|
| `glue_role_arn` | string | ARN da execution role Glue (Projeto 2) |
| `analytics_role_arn` | string | ARN da role Analytics (Projeto 2) |
| `access_role_arn` | null | Reservado; sempre null |

### Check Terraform

- `analytics_principals_same_account`: falha o plan/apply se o account id de algum ARN em `analytics_principal_arns` diferir de `data.aws_caller_identity.current.account_id`.

## APIs AWS consumidas

### Terraform apply (provider)

- IAM `CreateRole`, `CreatePolicy`, `AttachRolePolicy` (e equivalentes de update/delete)
- STS implícito na default credential chain (`GetCallerIdentity` via data source)

### Testes (`tests/simulate-principal-policy.*`)

- `terraform output -raw glue_role_arn` / `analytics_role_arn`
- `iam simulate-principal-policy` (GetObject/PutObject em ARNs S3)

## Modelos de Dados

Não há entidades persistidas neste repo. Nomes derivados:

- Glue role: `{project_prefix}-{environment}-glue-role`
- Analytics role: `{project_prefix}-{environment}-analytics-role`
- Policies: `{role-name}-policy`
- Tags: `Project`, `Environment`, `ManagedBy=terraform`
