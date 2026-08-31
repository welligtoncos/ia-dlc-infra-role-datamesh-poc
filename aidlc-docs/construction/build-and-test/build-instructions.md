# Instruções de Build

Incremento multi-env: dois roots Terraform (`bootstrap/` = U2; `identity/` = identidade U1+U3) e workflows GitHub Actions.

## Pré-requisitos

- **Ferramenta de Build**: Terraform >= 1.7.5 (CI pin 1.9.8)
- **Dependências**: AWS CLI v2 (simulate); provider `hashicorp/aws` ~> 5.0 (lockfiles em `identity/` e `bootstrap/`); GitHub Actions (pipelines)
- **Variáveis de Ambiente**: default chain para apply **local**; CI usa OIDC (`AWS_ROLE_ARN_DEV` / `_HOM` / `_PROD`, `AWS_REGION`)
- **Requisitos de Sistema**: Windows, Linux ou macOS; ~200 MB por `.terraform/`; rede no primeiro `init`

## Etapas de Build

### 1. Instalar Dependências

```powershell
terraform version   # >= 1.7.5
aws --version       # para simulate
```

### 2. Configurar Ambiente

**Bootstrap (uma vez por conta, admin):**

```powershell
Set-Location bootstrap
Copy-Item example.tfvars terraform.tfvars
# github_owner, github_repo, environment
```

**Identidade (local, Windows — sem `-var-file=`):**

```powershell
Set-Location ..\identity
Copy-Item env\dev.tfvars terraform.tfvars
# ARNs e buckets reais da conta deste environment
```

### 3. Compilar Todas as Unidades

**U2 — `bootstrap/`** (backend local):

```powershell
Set-Location bootstrap
terraform init
terraform fmt -check
terraform validate
terraform plan
```

**U3 — `identity/`** (backend S3; precisa do bootstrap já aplicado **ou** `init -backend=false` só para validate):

```powershell
Set-Location ..\identity
terraform init -backend=false
terraform fmt -check
terraform validate
```

Primeiro init **remoto** (conta já tinha state local):

```powershell
terraform init -backend-config=env/dev.backend.hcl -migrate-state
```

Conta nova:

```powershell
terraform init -backend-config=env/dev.backend.hcl
terraform plan
```

CI (Linux, `working-directory: identity`): `fmt -check` → `init -backend-config=env/{env}.backend.hcl` → `validate` → `plan -var-file=env/{env}.tfvars -out=tfplan` → `apply tfplan`.

### 4. Verificar Sucesso do Build

- **Saída Esperada**: `terraform validate` → `Success! The configuration is valid.` nos dois roots
- **Artefatos**: `.terraform/` local (gitignored); `.terraform.lock.hcl` em `identity/` e `bootstrap/` (git)
- **Avisos Comuns**: `backend "s3" {}` em `identity/` exige `-backend-config` ou `-backend=false`; PowerShell não usa `-var-file=` sem aspas

## Solução de Problemas

### Build Falha com Erros de Dependência

- **Causa**: sem rede no `init`; Terraform < 1.7.5
- **Solução**: atualizar Terraform; repetir `terraform init`

### Build Falha com Erros de Compilação

- **Causa**: `environment` fora de {dev,hom,prod}; `analytics_principal_arns` inválida; backend.hcl com bucket inexistente
- **Solução**: corrigir tfvars; aplicar U2 antes do init remoto; migrate se state local existir

### Init remoto vê state vazio e tenta recriar roles

- **Causa**: não rodou `-migrate-state` após POC v1
- **Solução**: em `identity/`, `terraform init -backend-config=env/{env}.backend.hcl -migrate-state` com admin **antes** do CI
