# Bootstrap — backend Terraform + OIDC GitHub

Aplica **uma vez por conta AWS** (`dev`, `hom` ou `prod`) com credencial **admin** na default chain. Cria o bucket de state, a tabela de lock, o OIDC provider do GitHub e a role que as pipelines (U3) vão assumir.

O state deste root é **local** (gitignored). Não use backend S3 aqui — o ovo-e-galinha: a role OIDC ainda não existe.

Pipelines GitHub Actions **não** estão neste diretório (unidade U3).

## O que cria

| Recurso | Nome padrão |
|---------|-------------|
| Bucket S3 (state da identidade) | `{project_prefix}-{environment}-tfstate` |
| Tabela DynamoDB (lock) | `{project_prefix}-{environment}-tf-lock` |
| OIDC GitHub | `token.actions.githubusercontent.com` |
| Deploy role | `{project_prefix}-{environment}-gha-deploy-role` |

Outputs: `state_bucket_name`, `lock_table_name`, `deploy_role_arn`, `oidc_provider_arn`, `aws_region`. Guarde o ARN da role para o GitHub Environment (U3).

Trust da deploy role: `aud` = `sts.amazonaws.com`; `repository` + `repository_owner`; e `sub` StringLike no formato **com IDs** (`repo:{owner}@{owner_id}/{repo}@{repo_id}:environment:{env}` e `:ref:refs/heads/{branch}`). A AWS recusa trust GitHub sem `sub`/`job_workflow_ref` restrito. Preencha `github_owner_id` e `github_repo_id` (saem do token OIDC). Isolamento entre contas AWS: uma role por conta.

## Requisitos

- Terraform >= 1.7.5, AWS Provider ~> 5.0
- Credenciais admin da **conta do ambiente** (default chain; sem `assume_role`)
- Permissão para criar S3, DynamoDB e IAM (OIDC provider + role/policy)

Repita o apply **três vezes**, uma por conta, com `environment` correspondente.

## Ir ao ar (PowerShell)

Copie `example.tfvars` para `terraform.tfvars` **dentro de** `bootstrap/`. Não use `-var-file=` no PowerShell: o `-` é interpretado pelo shell.

```powershell
Set-Location bootstrap
Copy-Item example.tfvars terraform.tfvars
# edite github_owner, github_repo e environment (dev | hom | prod)

terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
terraform output
```

Se o nome S3 convencional já existir no mundo, defina `state_bucket_name` no `terraform.tfvars`.

## Checklist por conta

1. Autenticar na conta do ambiente (não na conta de outro env).
2. Preencher `terraform.tfvars` (`environment` = essa conta).
3. `plan` + `apply` reais — `fmt`/`validate` sozinhos **não** deixam o bootstrap pronto.
4. Copiar outputs (principalmente `deploy_role_arn`) para configurar o GitHub Environment na U3.
5. Se a conta **já** tiver OIDC GitHub, o plan pode falhar com entity already exists. Importe:

```powershell
terraform import aws_iam_openid_connect_provider.github "arn:aws:iam::ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
```

Substitua `ACCOUNT_ID`. Depois `plan` de novo.

## Bucket policy HTTPS (`Deny` SecureTransport=false)

O provider AWS, o backend S3 e o GitHub Actions usam HTTPS. A policy **não** bloqueia a deploy role nem o Terraform.

Este root grava state **local**; a policy não compete com a escrita do `.tfstate` neste bucket (isso é da U3).

Se o `apply` retornar `AccessDenied` na `aws_s3_bucket_policy`: remova o resource `aws_s3_bucket_policy.state` em `s3.tf` (e o `data` associado) e reaplique. Nesta POC o provider já usa TLS.

## Destroy

Bucket e tabela têm `prevent_destroy` e `force_destroy = false`. Terraform recusa `destroy` até você remover o `lifecycle` **de propósito**.

Ordem:

1. Destruir a identidade (U1/U3) **antes** — o state remoto vive neste bucket.
2. Só então destruir o bootstrap (depois de tirar `prevent_destroy`).
3. Não destruir o bootstrap enquanto existir state da identidade neste S3.

Não há destroy nas pipelines (U3); destroy do bootstrap continua local/manual.

## Fora deste diretório

- `.github/workflows/` e `identity/env/*.tfvars` — U3
- Roles Glue/Analytics — `identity/`, não aqui
