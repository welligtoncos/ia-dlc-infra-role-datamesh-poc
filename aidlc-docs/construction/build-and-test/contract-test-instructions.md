# Instrucoes de Testes de Contrato

Contrato = outputs Terraform para o Projeto 2 (`shared-infrastructure.md`).

## Validar

Apos apply:

```bash
terraform output glue_role_arn
terraform output analytics_role_arn
terraform output access_role_arn
```

## Esperado

| Output | Esperado |
|--------|----------|
| `glue_role_arn` | ARN `...:role/{prefix}-{env}-glue-role` |
| `analytics_role_arn` | ARN `...:role/{prefix}-{env}-analytics-role` |
| `access_role_arn` | vazio / `null` |

Nomes de buckets/workgroup no `tfvars` devem ser os mesmos que o Projeto 2 criara. Esta unidade nao cria esses recursos; o contrato e so de **nomes + ARNs**.
