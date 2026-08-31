# Code Generation Plan — u3-identity-ci

**Este plano é a única fonte da verdade para a Geração de Código.** Parte 2 executada após aprovação (2026-08-31).

**Workspace root:** `d:\projetos-ia-aws\ia-dlc-infra-role-datamesh-poc`  
**Código:** raiz, `env/`, `.github/workflows/` (NUNCA `aidlc-docs/`). **Não** reescrever `glue.tf` / `analytics.tf`. **Não** regenerar `bootstrap/` (exceto README se um ponteiro U3 for útil — opcional, só se o README raiz não bastar).  
**Unidade:** `u3-identity-ci` — DeployService (EnvConfig + CiPipelines + backend no IdentityPlatform).  
**RFs:** RF-ME1, RF-ME2, RF-ME4, RF-ME5, RF-ME6, RF-ME7.  
**Dependências:** U2 aplicada na conta (operacional); outputs U2 vão para `backend.hcl` e GitHub vars.  
**DB app / API HTTP / Frontend:** N/A.

---

## Contexto

| Item | Valor |
|------|--------|
| Interfaces | `run(env)` → plan + apply remoto + simulate.sh |
| Entidades DB | Nenhuma nova (lock U2) |
| Limite | Workflows + env files + backend parcial + validation `environment`; sem resources AWS novos |

**Brownfield:** modificar `versions.tf`, `variables.tf`, `.gitignore`, `README.md`, `example.tfvars` (comentário). Criar `env/` e `.github/workflows/`.

---

## Etapas (Parte 2)

### Etapa 1 — Gitignore
- [x] `.gitignore`: manter `*.tfvars`; acrescentar `!env/*.tfvars` (além de `!example.tfvars` e `!bootstrap/example.tfvars`). `*.backend.hcl` **não** ignorar
- [x] **RFs:** RF-ME6, RNF-ME4

### Etapa 2 — Backend parcial e validation (root U1)
- [x] `versions.tf`: manter terraform `>= 1.7.5` e aws `~> 5.0`; adicionar `backend "s3" {}` **vazio**
- [x] `provider.tf`: **não** alterar (sem `assume_role`)
- [x] `variables.tf`: validation `environment` ∈ {`dev`,`hom`,`prod`}; atualizar description (não é mais “unico”)
- [x] `glue.tf` / `analytics.tf` / `outputs.tf`: **não** alterar
- [x] **RFs:** RF-ME1, RF-ME2

### Etapa 3 — EnvConfig
- [x] `env/dev.tfvars`, `env/hom.tfvars`, `env/prod.tfvars`: mesmos campos de `example.tfvars`; `environment` = nome do arquivo; buckets/workgroup/ARNs **placeholders** (formato IAM válido, account `123456789012`)
- [x] `env/dev.backend.hcl`, `hom.backend.hcl`, `prod.backend.hcl`: `bucket`, `dynamodb_table`, `region`, `key` = `datamesh-poc/{env}/identity.tfstate`, `encrypt = true`; nomes de bucket/tabela = convenção `{prefix}-{env}-tfstate` / `-tf-lock` (placeholders REPLACE se override U2)
- [x] `example.tfvars`: comentário “copiar de `env/dev.tfvars` (ou hom/prod) para `terraform.tfvars`”
- [x] **RFs:** RF-ME2, RF-ME6

### Etapa 4 — Reusable workflow (lógica)
- [x] `.github/workflows/deploy-identity.yml` (`on.workflow_call`)
- [x] Inputs: `environment_name`, `tfvars_path`, `backend_path`, `split_jobs` (bool), `github_environment` (string; usado só se `split_jobs`)
- [x] `permissions`: `contents: read`, `id-token: write`; job apply também `actions: read` (download artifact)
- [x] **Sem** `secrets: inherit`
- [x] `concurrency.group`: `identity-${{ inputs.environment_name }}`; `cancel-in-progress: false`
- [x] `timeout-minutes: 20` em cada job
- [x] Steps comuns: checkout `@v4` `persist-credentials: false`; `setup-terraform@v3` 1.9.8 `terraform_wrapper: false`; `configure-aws-credentials@v4` (`role-to-assume: ${{ vars.AWS_ROLE_ARN }}`, `aws-region: ${{ vars.AWS_REGION }}`) com **retry 3x + sleep** se falhar
- [x] `terraform fmt -check`; **job plan e job apply (e o job único do dev)** usam o **mesmo** `terraform init -input=false -backend-config=${{ inputs.backend_path }}` (retry 3x no init se AccessDenied). `inputs.backend_path` é o mesmo valor em todos os jobs do reusable — **não** hardcodar outro `.hcl` no apply. Se o apply init apontar para outro backend, o `tfplan` fica incompatível com o state (erro obscuro)
- [x] `terraform validate` e `terraform plan -var-file=${{ inputs.tfvars_path }} -out=tfplan -no-color` **após** o init do job plan (ou do job único)
- [x] `split_jobs=false` (dev): um job — init (`-backend-config=${{ inputs.backend_path }}`) → plan `-out` → `terraform apply -input=false tfplan` → simulate.sh. `sor_bucket`: nesta POC, grep/awk no tfvars (após o apply o backend já está configurado; **melhoria futura** se o grep quebrar: ler de `terraform output` ou de um output dedicado — **não** nesta geração)
- [x] `split_jobs=true` (hom/prod): job `plan` **sem** `environment:` — checkout, OIDC, setup-terraform, **`terraform init -input=false -backend-config=${{ inputs.backend_path }}`**, fmt-check, validate, plan `-out=tfplan`, upload artifact `tfplan` `retention-days: 1`. Job `apply` com `environment: ${{ inputs.github_environment }}`, `needs: plan`, `actions: read` — checkout, OIDC, setup-terraform, **de novo** `terraform init -input=false -backend-config=${{ inputs.backend_path }}` (filesystem limpo; **mesmo** `inputs.backend_path` que o plan), download artifact, `terraform apply -input=false tfplan`, simulate.sh
- [x] **RFs:** RF-ME4, RF-ME5, RF-ME7

### Etapa 5 — Callers
- [x] `deploy-dev.yml`: `on.push.branches: [dev]` + `workflow_dispatch`; `permissions` iguais; chama reusable `split_jobs: false`; `environment_name: dev`; **não** `environment:` no caller
- [x] `deploy-hom.yml`: branches `[hom]`; `split_jobs: true`; `github_environment: hom`
- [x] `deploy-prod.yml`: branches `[main]`; `split_jobs: true`; `github_environment: prod`
- [x] Cada caller só `on:` + `uses:` + `with:` (e `permissions` mínimas)
- [x] **RFs:** RF-ME4

### Etapa 6 — Camada API HTTP
- [x] N/A — skip

### Etapa 7 — Camada repositório / DB app
- [x] N/A — skip

### Etapa 8 — Frontend
- [x] N/A — skip

### Etapa 9 — Testes unitários de app
- [x] N/A — skip (simulate.sh já existe; CI chama; não duplicar script)

### Etapa 10 — Documentação
- [x] `README.md` raiz: (1) criar e publicar `origin/hom`; (2) bootstrap 3 contas → GitHub Environments `AWS_ROLE_ARN`/`AWS_REGION` + reviewers hom/prod; (3) **local:** copiar `env/{env}.tfvars` → `terraform.tfvars`, `init -backend-config=env/{env}.backend.hcl` (**`-migrate-state` uma vez** se state local existir); **sem** `-var-file` no PowerShell; **CI:** `-var-file`; (4) simulate `.ps1` local vs `.sh` no CI; (5) destroy **não** no CI; (6) fallback: se simulate no CI falhar por IAM, acrescentar `iam:SimulatePrincipalPolicy` na policy da U2
- [x] `terraform init -backend=false` + `fmt` + `validate` na raiz (sem AWS). Se validate exigir backend, documentar no summary
- [x] `aidlc-docs/construction/u3-identity-ci/code/code-generation-summary.md`
- [x] **RFs:** RNF-ME5

### Etapa 11 — Fechamento
- [x] Marcar etapas [x] neste plano
- [x] Atualizar `aidlc-state.md`

---

## Fora do plano

- Regenerar `bootstrap/*.tf` (exceto nota README de simulate)
- `force-unlock` no CI; cache de providers; matrix; Composite Action
- Trocar grep do `sor_bucket` por `terraform output` nesta geração (melhoria futura se o parse do tfvars quebrar)
- Extensões Security / Resiliency / PBT

## Contagem

11 etapas (4 N/A). Arquivos novos: `env/*`, `.github/workflows/deploy-*.yml`. Modificados: `versions.tf`, `variables.tf`, `.gitignore`, `README.md`, `example.tfvars`.
