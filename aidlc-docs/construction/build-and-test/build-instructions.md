# Instruções de Build

## Pré-requisitos

- **Ferramenta de Build**: Terraform >= 1.7.5
- **Dependências**: AWS CLI v2 (para simulate); provider `hashicorp/aws` ~> 5.0 (lockfile na raiz)
- **Variáveis de Ambiente**: credenciais AWS na default chain (`AWS_PROFILE` / `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY`)
- **Requisitos de Sistema**: Windows, Linux ou macOS; ~200 MB para `.terraform/`; rede no primeiro `init`

## Etapas de Build

### 1. Instalar Dependências

```bash
terraform version   # >= 1.7.5
aws --version       # opcional ate o simulate
```

### 2. Configurar Ambiente

```bash
cd d:/projetos-ia-aws/ia-dlc-infra-role-datamesh-poc
cp example.tfvars terraform.tfvars
# editar terraform.tfvars: buckets, workgroup, analytics_principal_arns da SUA conta
```

### 3. Compilar Todas as Unidades

Unidade unica `u1-identity-iam` (root Terraform):

```bash
terraform init
terraform fmt -check
terraform validate
terraform plan -var-file=terraform.tfvars -out=tfplan
```

`apply` e implantacao, nao compile:

```bash
terraform apply tfplan
```

### 4. Verificar Sucesso do Build

- **Saída Esperada**: `terraform validate` → `Success! The configuration is valid.`
- **Artefatos**: `.terraform/` (local), `.terraform.lock.hcl` (git), `tfplan` (opcional, nao commitar)
- **Avisos Comuns**: provider AWS baixa na primeira vez; `check` de conta so avalia no `plan` (precisa credencial)

## Solucao de Problemas

### Build Falha com Erros de Dependencia

- **Causa**: sem rede no `init`; versao Terraform < 1.7.5
- **Solucao**: atualizar Terraform; repetir `terraform init`

### Build Falha com Erros de Compilacao

- **Causa**: `analytics_principal_arns` vazia ou ARN invalido; `plan` sem credencial AWS
- **Solucao**: corrigir `terraform.tfvars`; configurar default chain; ARNs devem ser user/role da conta atual
