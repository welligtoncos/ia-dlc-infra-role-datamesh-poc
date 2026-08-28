# Unit of Work — InfraRoles Mini

## Visão

Uma unidade de trabalho (monólito IaC / serviço único). O loop de Construction executa uma vez.

| Campo | Valor |
|-------|--------|
| ID | `u1-identity-iam` |
| Tipo | Serviço implantável único (`IdentityPlatform`) |
| Contexto | Camada de Identidade da malha (POC) |
| Dono | P1 Engenheiro de dados |
| Apply | Um state local, um `apply`, um `destroy` |
| Histórias | US-1, US-2, US-3, US-4, US-5, US-6 |

## Responsabilidades

- Provisionar `GlueIdentity` e `AnalyticsIdentity` no mesmo apply
- Publicar `OutputContract` (`glue_role_arn`, `analytics_role_arn`, `access_role_arn = null`)
- Parametrizar prefixo, environment, região, buckets e `analytics_principal_arns` (sem criar buckets)
- Permitir validação US-5 no Build and Test desta unidade
- Destruir só os recursos desta unidade (não buckets do Projeto 2)

## Módulos lógicos (dentro da unidade, não unidades)

| Módulo | Papel |
|--------|--------|
| GlueIdentity | Execution role Glue |
| AnalyticsIdentity | Role de leitura governada |
| OutputContract | Outputs para o Projeto 2 |
| Bootstrap | Suporte: versions, provider, variables, tags, backend local |

## Organização de código (greenfield IaC)

O padrão genérico `src/` / `tests/` / `config/` **não** se aplica. Código na **raiz do workspace**:

```
<workspace-root>/
  versions.tf
  provider.tf
  variables.tf
  glue.tf
  analytics.tf
  outputs.tf
  .gitignore
  tests/                    # opcional: validacao (simulate / checks)
  aidlc-docs/               # documentacao AI-DLC somente
```

Sem `modules/iam-roles`. Sem role de Acesso (`access.tf` não existe).

## Construction desta unidade

Ordem no execution-plan: Functional Design → NFR Requirements → NFR Design → Infrastructure Design → Code Generation → Build and Test.

## Conformidade com extensões

| Extensão | Status |
|----------|--------|
| Security Baseline | N/A |
| Resiliency Baseline | N/A |
| Property-Based Testing | N/A |
