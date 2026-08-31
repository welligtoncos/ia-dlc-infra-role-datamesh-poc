# Execução de Testes Unitários

Não há testes de linguagem de aplicação. Equivalente: **validação estática** dos dois roots e `fmt -check` (o mesmo que o CI).

## Executar Testes Unitários

### 1. Executar Todos os Testes Unitários

```powershell
# Identidade
Set-Location identity
terraform init -backend=false
terraform fmt -check
terraform validate

# Bootstrap
Set-Location ..\bootstrap
terraform init
terraform fmt -check
terraform validate
```

Validações embutidas (identidade):

- `environment` ∈ {dev, hom, prod}
- `analytics_principal_arns` não vazia; formato ARN IAM
- `check` same-account no **plan** (precisa credencial)

### 2. Revisar Resultados dos Testes

- **Esperado**: validate sucesso; fmt sem diff nos dois roots
- **Cobertura**: N/A (IaC)
- **Relatório**: CLI

### 3. Corrigir Testes com Falha

1. Ler a mensagem do Terraform
2. Ajustar `.tf` ou tfvars
3. Reexecutar `fmt` / `validate`
