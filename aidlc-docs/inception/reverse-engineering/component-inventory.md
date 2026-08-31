# Inventário de Componentes

## Pacotes de Aplicação

- Nenhum (sem runtime de aplicação)

## Pacotes de Infraestrutura

- `identity-iam` (root Terraform na raiz do workspace) - Terraform - Roles e policies IAM Glue + Analytics

## Pacotes Compartilhados

- Nenhum módulo Terraform `modules/`
- Contrato documental com Projeto 2: `aidlc-docs/construction/shared-infrastructure.md`

## Pacotes de Teste

- `tests/` - scripts de `iam simulate-principal-policy` (PowerShell + shell); não são testes unitários automatizados em CI

## Contagem Total

- **Total de Pacotes**: 2 (root IaC + tests)
- **Aplicação**: 0
- **Infraestrutura**: 1
- **Compartilhados**: 0
- **Teste**: 1
