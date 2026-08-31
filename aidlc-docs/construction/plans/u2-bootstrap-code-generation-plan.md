# Code Generation Plan — u2-bootstrap

**Este plano é a única fonte da verdade para a Geração de Código.** Parte 2 executada após aprovação (2026-08-31).

**Workspace root:** `d:\projetos-ia-aws\ia-dlc-infra-role-datamesh-poc`  
**Código:** `bootstrap/` (NUNCA `aidlc-docs/`). Não mover `glue.tf` da raiz.  
**Unidade:** `u2-bootstrap` — BootstrapService, apply local uma vez por conta.  
**RFs:** RF-ME3 (primário); habilita RF-ME2 / RF-ME4.  
**Dependências:** nenhuma unidade Terraform; U3 consome outputs.  
**DB app / API HTTP / Frontend:** N/A.

---

## Contexto

| Item | Valor |
|------|--------|
| Interfaces | vars → `state_bucket_name`, `lock_table_name`, `deploy_role_arn`, `oidc_provider_arn`, `aws_region` |
| Entidades DB | DynamoDB lock table (não é app DB) |
| Limite | S3 state + DDB + OIDC GitHub + 1 deploy role; sem Glue/Analytics; sem workflows |

**Brownfield:** criar pasta nova `bootstrap/`; **modificar** `.gitignore` na raiz (não duplicar). `!example.tfvars` hoje só cobre a raiz — acrescentar `!bootstrap/example.tfvars`.

---

## Etapas (Parte 2)

### Etapa 1 — Estrutura e gitignore
- [x] Criar diretório `bootstrap/`
- [x] Atualizar `.gitignore` na raiz: manter regras atuais; garantir state/`.terraform` em qualquer pasta; `!bootstrap/example.tfvars`
- [x] **RFs:** RF-ME3, RNF-ME4

### Etapa 2 — Bootstrap Terraform (versions, provider, data, locals)
- [x] `bootstrap/versions.tf`: terraform `>= 1.7.5`, aws `~> 5.0`; **sem** backend S3
- [x] `bootstrap/provider.tf`: `region = var.aws_region`; default chain; sem `assume_role`
- [x] `bootstrap/data.tf`: `aws_caller_identity.current`, `aws_region.current`
- [x] `bootstrap/locals.tf`: nomes `{prefix}-{env}-tfstate` / `-tf-lock` / `-gha-deploy-role`; tags; thumbprint(s) OIDC GitHub estáticos (documentados AWS: `6938fd4d98bab03faadb97b34396831e3780aea3` e `1c58a3a8518e8759bf075b76b750d4f2df264fcd`); `oidc_url` = `https://token.actions.githubusercontent.com`
- [x] **RFs:** RF-ME3, RNF-ME1

### Etapa 3 — Variáveis e example.tfvars
- [x] `bootstrap/variables.tf`:
  - `project_prefix` (default `datamesh-poc`)
  - `environment` com validation ∈ {`dev`,`hom`,`prod`}
  - `aws_region` (default `sa-east-1`)
  - `github_owner`, `github_repo` (strings, obrigatórias)
  - `github_environment` (default = `var.environment`; validation igual ao env)
  - `state_bucket_name` opcional (`null` = convenção; senão override S3)
  - `lock_table_name` opcional (`null` = convenção)
- [x] `bootstrap/example.tfvars`: placeholders (owner/repo, env `dev`, sem account id secreto)
- [x] **RFs:** RF-ME1 (env enum), RF-ME3

### Etapa 4 — S3 state bucket
- [x] `bootstrap/s3.tf` (ou `state.tf`): bucket, versioning, SSE-S3, public access block (4 flags), `force_destroy = false`, `lifecycle { prevent_destroy = true }`, encryption config
- [x] Nome: `coalesce(var.state_bucket_name, "{prefix}-{env}-tfstate")`
- [x] **Bucket policy deny HTTP — decisão (revisão 2026-08-31):**
  - **Incluir** `aws_s3_bucket_policy` com `Deny` quando `aws:SecureTransport` = `false` (forçar HTTPS). Só essa condição — **não** deny por principal que possa expulsar o admin/Terraform.
  - **Deploy role e Terraform acessam o bucket:** sim. Provider AWS, backend S3 e o SDK do GitHub Actions usam **HTTPS**. `aws:SecureTransport` fica `true`; a Deny não impede Get/Put/Delete de state nem `terraform apply` da U3.
  - **Timing no apply do bootstrap:** o root U2 usa **backend local** (gitignored). O state **não** é gravado neste bucket no mesmo apply. O risco clássico “policy aplicada antes de gravar o `.tfstate` remoto no próprio bucket” **não ocorre na U2**. Chamadas `CreateBucket` / `PutBucketPolicy` vão pela API S3 em TLS.
  - **Teste obrigatório (engenheiro, não a Parte 2):** um `plan` + `apply` real numa conta de teste **antes** de tratar o bootstrap como pronto. A Parte 2 só faz `fmt`/`validate` (e `init` para lockfile).
  - **Fallback se `AccessDenied` no apply:** remover o resource `aws_s3_bucket_policy` (aceitar que `SecureTransport` já é true no provider) e reaplicar. README da Etapa 13 documenta esse recuo. Não adicionar KMS/deny extra nesta POC.
- [x] **RFs:** RF-ME2 (cria o backend), NFR Design Q1/Q4

### Etapa 5 — DynamoDB lock
- [x] `bootstrap/dynamodb.tf`: `PAY_PER_REQUEST`, hash `LockID` type S, PITR enabled, `prevent_destroy`
- [x] Nome: `coalesce(var.lock_table_name, "{prefix}-{env}-tf-lock")`
- [x] **RFs:** RF-ME2

### Etapa 6 — OIDC provider
- [x] `bootstrap/oidc.tf`: `aws_iam_openid_connect_provider` client_id `sts.amazonaws.com`, URL GitHub, thumbprints do local
- [x] **RFs:** RF-ME3

### Etapa 7 — Deploy role (negócio IAM)
- [x] `bootstrap/iam.tf`: trust `AssumeRoleWithWebIdentity`; `aud`; `sub` StringLike `repo:${owner}/${repo}:environment:${github_environment}`
- [x] Customer managed policy: IAM no prefixo `{prefix}-{env}-*` (roles/policies Glue/Analytics da U1); S3 no bucket de state (bucket + `/*`); DynamoDB Get/Put/Delete/Describe na tabela de lock
- [x] Sem `AdministratorAccess`; sem SOR/SOT/SPEC
- [x] **RFs:** RF-ME3, RF-ME7

### Etapa 8 — Outputs
- [x] `bootstrap/outputs.tf`: `state_bucket_name`, `lock_table_name`, `deploy_role_arn`, `oidc_provider_arn`, `aws_region`
- [x] **RFs:** contrato U3 / shared-infrastructure

### Etapa 9 — Camada API HTTP
- [x] N/A — skip

### Etapa 10 — Camada repositório / DB app
- [x] N/A — skip (DynamoDB já na Etapa 5)

### Etapa 11 — Frontend
- [x] N/A — skip

### Etapa 12 — Testes unitários de app
- [x] N/A — skip (sem simulate IAM das roles Glue aqui; `fmt`/`validate` na Etapa 13)

### Etapa 13 — Documentação e lockfile
- [x] `bootstrap/README.md`: init/fmt/validate/plan/apply/output; copiar outputs; import OIDC se já existir; aviso `prevent_destroy` e ordem destroy vs U3; **não** `-var-file` no PowerShell (copiar example → `terraform.tfvars` **dentro de** `bootstrap/`); **deny HTTPS**: por que não bloqueia Terraform/GHA; backend local na U2; se `AccessDenied` no apply → apagar a bucket policy e reaplicar
- [x] Seção curta no `README.md` da **raiz**: aponta para `bootstrap/` (setup multi-env; pipelines ainda U3)
- [x] `terraform init` em `bootstrap/` para `.terraform.lock.hcl` (commitável). Se falhar (rede), documentar no summary
- [x] `aidlc-docs/construction/u2-bootstrap/code/code-generation-summary.md`
- [x] **RFs:** RNF-ME5

### Etapa 14 — Fechamento
- [x] Marcar etapas [x] neste plano
- [x] `terraform fmt` + `terraform validate` em `bootstrap/` se init ok
- [x] Atualizar `aidlc-state.md`

---

## Fora do plano

- `.github/workflows/`, `env/*.tfvars`, backend no root U1 (U3)
- `hashicorp/tls`, KMS CMK, `force_destroy`, três roles na mesma conta
- Extensões Security / Resiliency / PBT

## Contagem

14 etapas (4 N/A). Arquivos em `bootstrap/`: versions, provider, data, locals, variables, example.tfvars, s3, dynamodb, oidc, iam, outputs, README, lockfile.
