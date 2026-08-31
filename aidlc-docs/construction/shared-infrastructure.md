# Shared Infrastructure — contratos (Projeto 2 + multi-env)

Este repositório (Projeto 1) **não cria** a malha de dados. O Projeto 2 deve usar os **mesmos nomes** e a **mesma conta/região do ambiente**.

## Conta e região

| Item | Contrato |
|------|----------|
| Contas | Três contas fixas: uma para `dev`, uma para `hom`, uma para `prod` |
| Região | `aws_region` (default `sa-east-1`) |
| Prefixo | `project_prefix` (default `datamesh-poc`) |
| Ambiente | `environment` ∈ {`dev`, `hom`, `prod`} |

Cada apply de identidade e cada apply de bootstrap usam **a conta daquele ambiente**.

## Backend Terraform da identidade (U2 cria; U3 usa)

Criado por `bootstrap/` **uma vez por conta**. State do bootstrap é local; state da identidade é remoto neste backend.

| Recurso | Convenção | Uso |
|---------|-----------|-----|
| Bucket S3 | `{project_prefix}-{environment}-tfstate` (override se nome global ocupado) | State U3 |
| Tabela DynamoDB | `{project_prefix}-{environment}-tf-lock` | Lock (`LockID`) |
| OIDC GitHub | `token.actions.githubusercontent.com` na conta | Trust da deploy role |
| Deploy role | `{project_prefix}-{environment}-gha-deploy-role` | GitHub Actions assume via OIDC (`repository` + `repository_owner`; uma role por conta AWS) |

Outputs U2: `state_bucket_name`, `lock_table_name`, `deploy_role_arn`, `oidc_provider_arn`, `aws_region`. U3 preenche `identity/env/{env}.backend.hcl` e vars do GitHub Environment.

### CI e GitHub (U3)

| Item | Contrato |
|------|----------|
| Callers | `.github/workflows/deploy-dev.yml`, `deploy-hom.yml`, `deploy-prod.yml` |
| Reusable | `.github/workflows/deploy-identity.yml` |
| Environments | `dev`, `hom`, `prod` (mesmo nome do claim OIDC) |
| Vars por Environment | `AWS_ROLE_ARN` (output U2 `deploy_role_arn`), `AWS_REGION` |
| State key | `{project_prefix}/{environment}/identity.tfstate` (ex. `datamesh-poc/dev/identity.tfstate`) |
| backend.hcl | `bucket`, `dynamodb_table`, `region`, `key`, `encrypt = true` |
| Actions | `actions/checkout@v4`, `aws-actions/configure-aws-credentials@v6` (Node 24), `hashicorp/setup-terraform@v3` (TF 1.9.8) |
| Plan file | Artifact GitHub `tfplan`, retention 1 dia — não no S3 |

### Ordem de setup (U3)

1. Bootstrap (U2) na conta N — admin local; copiar outputs.
2. GitHub Environment `N` com `AWS_ROLE_ARN` + `AWS_REGION`; reviewers se hom/prod.
3. Branch remota `hom` publicada **antes** do primeiro push hom.
4. Se a conta **já** tinha apply com backend **local**: `terraform init -backend-config=env/{env}.backend.hcl -migrate-state` em `identity/` (admin, uma vez). CI **não** migra.
5. Pipeline (push/dispatch) ou apply local com `terraform.tfvars` copiado.
6. Projeto 2 na **mesma** conta N.

Contas nunca aplicadas: init remoto cria state vazio; o primeiro apply popula. Não descartar state local da POC v1 sem migrate — recriar roles muda ARNs e quebra o Projeto 2.

## Nomes que o Projeto 2 deve criar / possuir

| Recurso | Variável neste projeto | Uso |
|---------|------------------------|-----|
| Bucket camada SOR | `sor_bucket` | Glue R/W/list; Analytics list/read |
| Bucket camada SOT | `sot_bucket` | idem |
| Bucket camada SPEC | `spec_bucket` | idem |
| Bucket resultados Athena | `athena_results_bucket` | Analytics R/W |
| Workgroup Athena | `athena_workgroup` | Analytics query |

Schema Glue (databases/tables) é **IaC-owned no Projeto 2**. Jobs/crawlers assumem `glue_role_arn`.

## O que o Projeto 2 consome do apply de identidade

| Output | Significado |
|--------|-------------|
| `glue_role_arn` | Execution role Glue |
| `analytics_role_arn` | Role de leitura governada |
| `access_role_arn` | Sempre `null` nesta POC |

## Ordem

1. Bootstrap (U2) na conta N — admin local.
2. GitHub Environments + migrate se state local (U3 setup).
3. Identidade (U1/U3) na conta N — CI ou local com backend remoto.
4. Projeto 2 na **mesma** conta N (buckets/workgroup).

Identidade **pode** ser aplicada **antes** dos buckets/workgroup existirem. O Projeto 2 não deve destruir as roles; o destroy da identidade não deve destruir buckets. **Não** destruir o bootstrap (S3/DDB) enquanto existir state da identidade nesse bucket (`prevent_destroy`).
