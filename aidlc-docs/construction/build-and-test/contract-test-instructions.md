# Instruções de Testes de Contrato

Contrato com o **Projeto 2** (outputs da identidade) e contrato **U2 → U3** (backend).

## Após apply da identidade

```powershell
Set-Location identity
terraform output glue_role_arn
terraform output analytics_role_arn
terraform output access_role_arn
```

Esperado: dois ARNs IAM; `access_role_arn` = `null`.

Nomes: `{project_prefix}-{environment}-glue-role` / `-analytics-role`.

## Contrato backend

`identity/env/{env}.backend.hcl`: `key` = `{prefix}/{env}/identity.tfstate`; `encrypt = true`. Bucket/tabela = outputs U2 (convenção ou override).

Ver `aidlc-docs/construction/shared-infrastructure.md`.
