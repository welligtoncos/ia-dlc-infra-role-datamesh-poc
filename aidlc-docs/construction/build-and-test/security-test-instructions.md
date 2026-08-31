# Instruções de Testes de Segurança

Não é pentest. Extensão Security Baseline **desabilitada**. Foco: OIDC, gitignore, simulate IAM.

## Autorização (simulate)

**Local (Windows), após apply da identidade:**

```powershell
Set-Location identity
..\tests\simulate-principal-policy.ps1 -SorBucket "<sor_bucket>"
```

**CI (Linux):** `tests/simulate-principal-policy.sh` (o workflow já chama). Não usar `.ps1` no Actions.

Esperado: Glue allow GetObject na POC; deny fora; Analytics allow GetObject; deny PutObject na camada.

Se falhar logo após apply: esperar 10–20 s. Se AccessDenied em `SimulatePrincipalPolicy`, emendar a policy da deploy role no bootstrap.

## Checks estáticos

- Sem access keys nos workflows
- Trust OIDC: `aud` + `sub` environment **e** ref da branch (job plan)
- `.gitignore`: `*.tfstate*`; `*.tfvars` com exceções `identity/example.tfvars`, `bootstrap/example.tfvars`, `identity/env/*.tfvars`
- Artifact `tfplan` retention 1 dia; não no S3

## Dependências

Lockfiles `hashicorp/aws` ~> 5.0. Sem SCA obrigatório.
