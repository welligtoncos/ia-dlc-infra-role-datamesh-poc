# Unit of Work Story Map — InfraRoles Mini

Todas as histórias atribuídas. Nenhuma história órfã.

## Mapa unidade → histórias

| Unidade | Histórias | Notas |
|---------|-----------|--------|
| `u1-identity-iam` | US-1, US-2, US-3, US-4, US-5, US-6 | Loop único de Construction |

## Mapa história → unidade / módulo lógico

| História | Unidade | Módulo lógico / operação | Persona-dona |
|----------|---------|--------------------------|--------------|
| US-1 Execution role Glue | `u1-identity-iam` | GlueIdentity | P1 |
| US-2 Role Analytics | `u1-identity-iam` | AnalyticsIdentity | P2 |
| US-3 Contrato de outputs | `u1-identity-iam` | OutputContract | P1 |
| US-4 Parametrização | `u1-identity-iam` | Bootstrap / variáveis do root | P1 |
| US-5 Menor privilégio | `u1-identity-iam` | Build and Test da unidade (não é componente) | P1 |
| US-6 Destroy limpo | `u1-identity-iam` | `IdentityPlatform.destroy` | P1 |

## Cobertura

| ID | Atribuída | Unidade |
|----|-----------|---------|
| US-1 | sim | u1-identity-iam |
| US-2 | sim | u1-identity-iam |
| US-3 | sim | u1-identity-iam |
| US-4 | sim | u1-identity-iam |
| US-5 | sim | u1-identity-iam |
| US-6 | sim | u1-identity-iam |

Atores de aceite (Glue Job, Não-consumidor, Projeto 2) não geram unidades.
