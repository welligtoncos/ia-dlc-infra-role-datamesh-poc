# Instrucoes de Testes de Integracao

Uma unidade apenas. Integracao = **IAM na conta** + **contrato de nomes com o Projeto 2** (externo).

## Cenarios de Teste

### Cenario 1: Apply cria as duas identidades e o contrato

- **Descricao**: `terraform apply` materializa Glue + Analytics e os tres outputs
- **Setup**: `terraform.tfvars` valido; credencial admin IAM
- **Etapas**: `terraform apply -var-file=terraform.tfvars`
- **Resultados Esperados**: apply sem erro; `glue_role_arn` e `analytics_role_arn` preenchidos; `access_role_arn` null
- **Limpeza**: `terraform destroy -var-file=terraform.tfvars` (nao apaga buckets)

### Cenario 2: Trust Analytics rejeita Nao-consumidor

- **Descricao**: ARN fora de `analytics_principal_arns` nao assume a role
- **Setup**: identidade extra na conta, nao listada
- **Etapas**: `aws sts assume-role --role-arn <analytics_role_arn> --role-session-name test` com o Nao-consumidor
- **Resultados Esperados**: AccessDenied
- **Limpeza**: nenhuma

### Cenario 3: Glue assume (quando houver job no Projeto 2)

- **Descricao**: Job Glue usa `glue_role_arn`
- **Setup**: Projeto 2 (opcional nesta POC)
- **Etapas**: apontar o job para o output Glue
- **Resultados Esperados**: assume permitido (servico Glue + SourceAccount)
- **Limpeza**: a cargo do Projeto 2

## Configurar Ambiente

Nao ha docker-compose. So AWS + Terraform.

## Executar

Nao ha suite Maven/npm. Use apply + CLI conforme acima.

## Limpeza

```bash
terraform destroy -var-file=terraform.tfvars
```
