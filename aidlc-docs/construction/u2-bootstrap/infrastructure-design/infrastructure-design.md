# Infrastructure Design — u2-bootstrap

## Provedor e ambiente

| Item | Escolha |
|------|---------|
| Cloud | AWS comercial |
| Contas | Uma por apply (dev, hom ou prod); repetir o root três vezes |
| Região | `var.aws_region` default `sa-east-1` |
| Auth provider | Default credential chain **admin**; sem `assume_role`; sem `aws_profile` obrigatório |
| Terraform | `>= 1.7.5`, só `hashicorp/aws ~> 5.0`, lockfile em `bootstrap/` |
| Backend deste root | Local (gitignored) |

## Mapeamento lógico → AWS

| Lógico | AWS | Notas |
|--------|-----|--------|
| State backend U3 | `aws_s3_bucket` + versioning + BPA + SSE-S3 + public access block | `prevent_destroy`; `force_destroy = false`; override de nome se colisão global |
| Lock U3 | `aws_dynamodb_table` billing `PAY_PER_REQUEST`, hash `LockID` (S), PITR | `prevent_destroy` |
| GitHub OIDC | `aws_iam_openid_connect_provider` URL `https://token.actions.githubusercontent.com` | Thumbprint estático; `terraform import` se já existir |
| Deploy role | `aws_iam_role` + customer managed `aws_iam_policy` + attachment | Trust federated OIDC |
| BootstrapGitIgnore / ExampleTfvars / Lockfile / Readme / OidcThumbprint | arquivos no repo | Não são recursos AWS |

## Não provisionar nesta unidade

EC2, Lambda, ECS, Glue/Analytics roles, VPC, SQS/SNS/EventBridge, CloudWatch alarms, GitHub workflow, buckets de dados do Projeto 2.

## Nomes (convenção + override)

| Recurso | Convenção | Override |
|---------|-----------|----------|
| Bucket state | `{project_prefix}-{environment}-tfstate` | variável se o nome S3 já existir no mundo |
| Tabela lock | `{project_prefix}-{environment}-tf-lock` | opcional |
| Deploy role | `{project_prefix}-{environment}-gha-deploy-role` | — |
| Policy | `{role}-policy` | — |

`environment` ∈ {dev, hom, prod}. Tags: `Project`, `Environment`, `ManagedBy=terraform`.

## IAM — deploy role

**Trust**
- Principal: federated `arn:aws:iam::{account}:oidc-provider/token.actions.githubusercontent.com`
- Action: `sts:AssumeRoleWithWebIdentity`
- Condition: `aud` = `sts.amazonaws.com`; `sub` StringLike `repo:{github_owner}/{github_repo}:environment:{github_environment}`
- `github_environment` deve ser o mesmo `environment` da conta (dev/hom/prod)

**Permissions (customer managed)** — o necessário para a U3 aplicar o root de identidade **e** usar o backend:
- IAM: criar/atualizar/anexar roles e policies no perímetro desta POC (prefixo de nomes), GetRole, PassRole se necessário para IAM-only
- S3: List/Get/Put/Delete no bucket de **state** (objetos `/*` + bucket)
- DynamoDB: Get/Put/Delete/Query no item de lock da tabela criada aqui

Sem `AdministratorAccess`. Sem acesso aos buckets SOR/SOT/SPEC (isso é Glue/Analytics).

## OIDC provider já existente

Resource gerenciado por este root. README: se o plan falhar com entity already exists → `terraform import aws_iam_openid_connect_provider.github <ARN>`.

## Outputs (contrato U3)

| Output | Uso |
|--------|-----|
| `state_bucket_name` | `backend.hcl` / `-backend-config` |
| `lock_table_name` | idem |
| `deploy_role_arn` | GitHub Environment variable |
| `oidc_provider_arn` | diagnóstico |
| `aws_region` | backend region |

## S3 / DynamoDB — detalhe

- Bucket: encryption SSE-S3; versioning; `block_public_acls`, `ignore_public_acls`, `block_public_policy`, `restrict_public_buckets`; policy Deny `aws:SecureTransport=false` (só HTTPS). U2 state é local — a policy não compete com gravação de state neste bucket. Se `AccessDenied` no apply, omitir a policy (POC).
- Sem `force_destroy`
- DynamoDB: attribute `LockID` type S; `point_in_time_recovery` enabled
