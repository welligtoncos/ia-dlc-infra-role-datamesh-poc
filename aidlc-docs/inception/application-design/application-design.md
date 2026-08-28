# Application Design — InfraRoles Mini

Consolidado do design de aplicação (IaC). Detalhe de policies → Design Funcional. Mapeamento AWS → Design de Infraestrutura.

## Decisões

| Tema | Decisão |
|------|---------|
| Componentes | `GlueIdentity`, `AnalyticsIdentity`, `OutputContract` |
| Bootstrap | Suporte do root, não componente |
| Serviço | `IdentityPlatform` = um `apply` coeso; rótulo, não fachada |
| Composição | Plana no root (`glue.tf`, `analytics.tf`, outputs) |
| Acoplamento roles | Só variáveis compartilhadas |
| Outputs | Contrato depende das duas identidades; `access_role_arn = null` |
| US-5 | Build and Test, não componente |
| Interfaces | Ciclo Terraform + configure/role_arn por identidade |

## Componentes

Ver `components.md`. Três blocos; sem role de Acesso; sem criação de buckets.

## Interfaces

Ver `component-methods.md`. `IdentityPlatform`: `plan` / `apply` / `output` / `destroy`. Identidades: `configure(...)` → `role_arn`. Contrato: `bind(...)` → três outputs.

## Serviço

Ver `services.md`. Orquestração em um apply; identidades em paralelo lógico.

## Dependências

Ver `component-dependency.md`. OutputContract lê as duas identidades. Glue e Analytics não se referenciam.

## Rastreio histórias

| História | Onde no design |
|----------|----------------|
| US-1 | GlueIdentity |
| US-2 | AnalyticsIdentity |
| US-3 | OutputContract |
| US-4 | Variáveis do bootstrap / IdentityPlatform |
| US-5 | Fora — Build and Test |
| US-6 | `IdentityPlatform.destroy` |

## Conformidade com extensões

| Extensão | Status | Justificativa |
|----------|--------|---------------|
| Security Baseline | N/A | Desabilitada |
| Resiliency Baseline | N/A | Desabilitada |
| Property-Based Testing | N/A | Desabilitada |
