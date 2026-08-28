# Instrucoes de Testes de Seguranca

Nao e pentest. Foco: menor privilegio (US-5) e higiene do repo.

## Autorizacao (simulate)

Apos apply, na raiz:

```powershell
.\tests\simulate-principal-policy.ps1 -SorBucket "<sor_bucket>"
```

```bash
bash tests/simulate-principal-policy.sh "<sor_bucket>"
```

Esperado:

- Glue **allow** `s3:GetObject` no bucket da POC
- Glue **deny**/implicit deny em bucket fora da POC
- Analytics **allow** GetObject na camada
- Analytics **deny** PutObject na camada

Se falhar logo apos o apply: esperar 10–20 s (consistencia IAM) e repetir.

## Checks estaticos

- Nenhuma AWS managed `*FullAccess`
- `Resource: "*"` so em `lakeformation:GetDataAccess` (comentado no `.tf`)
- `.gitignore` cobre state e `*.tfvars` (exceto `example.tfvars`)
- `example.tfvars` so placeholders

## Dependencias

Provider pinado em `.terraform.lock.hcl`. Sem scanner SCA obrigatorio (extensao Security desabilitada).
