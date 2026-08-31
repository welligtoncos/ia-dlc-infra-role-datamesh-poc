# Infrastructure Design — u3-identity-ci

## Provedor e ambiente

| Item | Escolha |
|------|---------|
| CI | GitHub.com Actions (não GHES) |
| Contas AWS | As três da U2; esta unidade **não** cria conta, bucket, OIDC nem deploy role |
| Região | `AWS_REGION` no GitHub Environment; Terraform `var.aws_region` (default `sa-east-1`) |
| Auth CI | `aws-actions/configure-aws-credentials@v4` OIDC; `role-to-assume` = `vars.AWS_ROLE_ARN` do Environment `dev`\|`hom`\|`prod` |
| Auth local | Default credential chain **admin** da conta do env; `provider.tf` **sem** `assume_role` |
| Terraform no CI | `hashicorp/setup-terraform@v3`, `terraform_version` **1.9.8**, `terraform_wrapper: false` |
| Terraform nos `.tf` | `>= 1.7.5`, `hashicorp/aws ~> 5.0` (lockfile em `identity/`) |
| Checkout | `actions/checkout@v4`, `persist-credentials: false` |
| Backend identidade | `backend "s3" {}` vazio em `identity/`; config em `identity/env/{env}.backend.hcl` |

## Mapeamento lógico → infra

| Lógico | Infra real | Notas |
|--------|------------|--------|
| ReusableDeployWorkflow | `.github/workflows/deploy-identity.yml` (`workflow_call`) | fmt-check, OIDC+retry, init, validate, plan `-out`, artifact, apply `tfplan`, simulate.sh |
| DeployCallerDev | `.github/workflows/deploy-dev.yml` | push `dev` + `workflow_dispatch`; um job; sem aprovação |
| DeployCallerHom | `.github/workflows/deploy-hom.yml` | push `hom` + dispatch; plan + apply; Environment `hom` só no apply |
| DeployCallerProd | `.github/workflows/deploy-prod.yml` | push `main` + dispatch; Environment `prod` só no apply |
| EnvTfvars | `identity/env/{dev,hom,prod}.tfvars` | commitados; placeholders |
| BackendHcl | `identity/env/{dev,hom,prod}.backend.hcl` | ver tabela abaixo |
| IdentityBackendPartial | `backend "s3" {}` em `versions.tf` (raiz) | sem bucket no `.tf` |
| EnvironmentValidation | `variables.tf` validation ∈ {dev,hom,prod} | glue/analytics inalterados |
| ConcurrencyGroup | `concurrency.group: identity-{env}` | `cancel-in-progress: false` |
| GitIgnoreEnvTfvarsAllow | `.gitignore` `!identity/env/*.tfvars` | `terraform.tfvars` continua ignorado |
| IdentityCiReadme | `README.md` raiz | hom, migrate, var-file, Environments |
| Plan artifact | GitHub Actions artifact `tfplan` | retention 1 dia; **não** no S3 |
| Glue/Analytics | recursos **já** no root U1 | apply via CI/local; sem resources novos |

## Não provisionar nesta unidade

EC2, Lambda, CodeBuild, VPC, SQS/SNS/EventBridge, CloudWatch, S3/DDB/OIDC/deploy role (U2), buckets SOR/SOT/SPEC, `assume_role` no provider.

## backend.hcl (contrato)

| Campo | Valor |
|-------|--------|
| `bucket` | output U2 `state_bucket_name` (conv. `{prefix}-{env}-tfstate`) |
| `dynamodb_table` | output U2 `lock_table_name` |
| `region` | `sa-east-1` (ou a região do bootstrap) |
| `key` | `{project_prefix}/{environment}/identity.tfstate` (ex. `datamesh-poc/dev/identity.tfstate`) |
| `encrypt` | `true` |

## GitHub Environment

| Environment | Aprovação | Vars |
|-------------|-----------|------|
| `dev` | não | `AWS_ROLE_ARN`, `AWS_REGION` |
| `hom` | sim (required reviewers) | idem |
| `prod` | sim | idem |

Nomes dos Environments **iguais** ao claim OIDC `environment:{env}`. Sem access keys. Sem `secrets: inherit` no reusable.

## State local da POC v1

Se a conta **já** teve apply com backend local, o engenheiro (admin) roda **uma vez**:

Em `identity/`: `terraform init -backend-config=env/{env}.backend.hcl -migrate-state`

CI **não** faz migrate. Contas novas: init remoto (state vazio) + primeiro apply.

## IAM

A deploy role (U2) já cobre IAM do prefixo + S3/DDB de state. U3 não cria policy nova. Simulate no CI usa as mesmas permissões `iam:SimulatePrincipalPolicy` — se o simulate falhar por falta de permissão na deploy role, **emendar a policy na U2** (não nesta unidade na geração inicial; documentar no README se o simulate exigir `iam:Simulate*`).

Nota: a policy U2 atual foca create/update de roles Glue/Analytics. Simulate pode precisar de `iam:SimulatePrincipalPolicy` e `iam:GetContextKeysForPrincipalPolicy`. Se faltar no primeiro run real, é correção de bootstrap — registrar no README da U3 como fallback.
