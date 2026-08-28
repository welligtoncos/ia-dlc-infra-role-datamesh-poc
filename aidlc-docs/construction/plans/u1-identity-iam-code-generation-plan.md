# Code Generation Plan — u1-identity-iam

**Este plano é a única fonte da verdade para a Geração de Código.** Parte 2 executa só após aprovação explícita.

**Workspace root:** `d:\projetos-ia-aws\ia-dlc-infra-role-datamesh-poc`  
**Código:** raiz do repo (NUNCA `aidlc-docs/`). IaC: **não** usar `src/` genérico.  
**Unidade:** `u1-identity-iam` — IdentityPlatform, um apply.  
**Histórias:** US-1 … US-6  
**Dependências:** nenhuma unidade interna; Projeto 2 consome outputs.  
**DB / API HTTP / Frontend / Repository:** N/A.

---

## Contexto

| Item | Valor |
|------|--------|
| Interfaces | vars → two role ARNs + `access_role_arn=null` |
| Entidades DB | Nenhuma |
| Limite | Só IAM; não cria buckets/jobs/workgroup |

---

## Etapas (Parte 2)

### Etapa 1 — Estrutura greenfield
- [x] Criar `.gitignore` (`.terraform/`, `*.tfstate*`, `*.tfvars`, crash.log, override files)
- [x] **Histórias:** US-4, RNF4/RNF7

### Etapa 2 — Bootstrap (versions, provider, data, locals)
- [x] `versions.tf`: terraform `>= 1.7.5`, aws `~> 5.0`
- [x] `provider.tf`: `region = var.aws_region`; default credential chain
- [x] `data.tf`: `aws_caller_identity.current`, `aws_region.current` se útil
- [x] `locals.tf`: nomes `{prefix}-{env}-glue-role` / `-analytics-role`; tags `Project`, `Environment`, `ManagedBy=terraform`
- [x] **Histórias:** US-4, RNF1, RNF5, RNF8

### Etapa 3 — Variáveis e exemplo
- [x] `variables.tf`: `project_prefix` (default `datamesh-poc`), `environment` (default `dev`), `aws_region` (default `sa-east-1`), `sor_bucket`, `sot_bucket`, `spec_bucket`, `athena_results_bucket`, `athena_workgroup`, `analytics_principal_arns` (list, validation: length > 0; cada ARN `iam::{account}:user/` ou `role/`; account = `data` só na policy/trust — validation de formato + `contains` account via `data` no resource, ou `validation` com regex de ARN IAM)
- [x] `example.tfvars`: placeholders, sem ARNs reais
- [x] **Histórias:** US-4, BR-VAL

### Etapa 4 — GlueIdentity (lógica de negócio / IAM)
- [x] `glue.tf`: role, customer managed policy, attachment; trust Glue + `SourceAccount`; S3 R/W/list/multipart sem delete; Glue Get/List + partitions; LF GetDataAccess `*` comentado; logs `/aws-glue/*` comentado
- [x] **Histórias:** US-1

### Etapa 5 — AnalyticsIdentity
- [x] `analytics.tf`: role, policy, attachment; trust lista de ARNs; S3 read camadas; R/W resultados Athena; Glue read; Athena workgroup; LF `*` comentado
- [x] **Histórias:** US-2

### Etapa 6 — OutputContract
- [x] `outputs.tf`: `glue_role_arn`, `analytics_role_arn`, `access_role_arn = null`
- [x] **Histórias:** US-3, US-6 (destroy implícito nos resources)

### Etapa 7 — Camada API HTTP
- [x] N/A — skip (sem API)

### Etapa 8 — Camada repositório / DB
- [x] N/A — skip

### Etapa 9 — Frontend
- [x] N/A — skip

### Etapa 10 — Testes (US-5)
- [x] `tests/simulate-principal-policy.sh` e/ou `.ps1` (Windows): documentar simulate allow/deny; nota de espera IAM se falha transitória
- [x] **Histórias:** US-5

### Etapa 11 — Documentação e implantação
- [x] `README.md`: init, fmt, validate, plan, apply, output, destroy, simulate, ordem vs Projeto 2
- [x] Tentar `terraform init` para gerar `.terraform.lock.hcl` (commitável). Se init falhar (sem rede), documentar no summary para o P1 gerar o lockfile
- [x] `aidlc-docs/construction/u1-identity-iam/code/code-generation-summary.md`
- [x] **Histórias:** US-4, US-5, US-6

### Etapa 12 — Fechamento
- [x] Marcar etapas [x] neste plano
- [x] Atualizar `aidlc-state.md`

---

## Fora do plano

- `access.tf`, `modules/`, criação de S3/Glue/Athena, CI, Makefile
- Extensões Security / Resiliency / PBT

## Contagem

12 etapas (3 N/A). Arquivos principais na raiz: `.gitignore`, `versions.tf`, `provider.tf`, `data.tf`, `locals.tf`, `variables.tf`, `example.tfvars`, `glue.tf`, `analytics.tf`, `outputs.tf`, `README.md`, `tests/simulate-*`.
