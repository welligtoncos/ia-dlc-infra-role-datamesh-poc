# Execucao de Testes Unitarios

Nao ha testes de linguagem de aplicacao. O equivalente e **validacao estatica do Terraform**.

## Executar Testes Unitarios

### 1. Executar Todos os Testes Unitarios

Na raiz do workspace:

```bash
terraform fmt -check -recursive
terraform validate
```

Validacoes embutidas (falham no `plan`/`validate` conforme o caso):

- `analytics_principal_arns` nao vazia
- cada ARN no formato `arn:aws:iam::ACCOUNT:(user|role)/...`
- `check` `analytics_principals_same_account` (no **plan**, com credencial)

### 2. Revisar Resultados dos Testes

- **Esperado**: validate sucesso; fmt sem diff
- **Cobertura**: N/A (IaC)
- **Relatorio**: saida do CLI

Ja executado nesta sessao: `terraform validate` → sucesso (apos `init`).

### 3. Corrigir Testes com Falha

1. Ler a mensagem do Terraform
2. Ajustar `.tf` ou `terraform.tfvars`
3. Reexecutar `fmt` / `validate`
