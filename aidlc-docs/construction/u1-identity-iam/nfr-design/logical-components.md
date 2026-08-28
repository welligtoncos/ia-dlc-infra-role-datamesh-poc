# Logical Components — u1-identity-iam

Componentes lógicos **NFR** (não são GlueIdentity / AnalyticsIdentity / OutputContract). Sem fila, cache ou circuit breaker.

| Componente | Responsabilidade |
|------------|------------------|
| GitIgnore | Excluir state local, backups de state, `*.tfvars` (inclui `terraform.tfvars`), `.terraform/` |
| ExampleTfvars | Placeholder commitado: prefix, env, região, buckets, workgroup, ARNs fictícios |
| Lockfile | `.terraform.lock.hcl` versionado (provider AWS reproduzível) |
| Readme | fmt/validate/apply/output/destroy; US-5; nota de espera IAM se simulate falhar de forma transitória |
| SimulateScript | `tests/` — comandos `simulate-principal-policy` (allow no perímetro, deny fora; Não-consumidor). Sem retry de `apply` |

## Integração

```
P1 -> Terraform CLI (retry nativo do provider)
     -> identidades + contrato
     -> SimulateScript (opcional wait documentado)
GitIgnore protege state e tfvars reais
ExampleTfvars e Lockfile entram no git
Readme descreve o caminho feliz e o wait de consistencia
```

## Fora deste desenho

- Makefile
- CI
- CloudWatch alarms
- Backend remoto
