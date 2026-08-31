# Application Design — Incremento multi-env

Consolidado. Policies Glue/Analytics → Design Funcional (SKIP neste incremento; texto POC v1 permanece válido). AWS/OIDC detalhado → Infrastructure Design.

## Decisões (este incremento)

| Tema | Q | Decisão |
|------|---|---------|
| Componentes novos | Q1-A | `BootstrapStack`, `EnvConfig`, `CiPipelines` |
| Componentes POC v1 | — | `GlueIdentity`, `AnalyticsIdentity`, `OutputContract` inalterados |
| Interfaces | Q2-C | Terraform nos dois roots + `CiPipelines.run(env)`; sem destroy no CI |
| Serviços | Q3-A | `BootstrapService` e `DeployService` |
| Dependência bootstrap | Q4-A | Só operacional; sem `terraform_remote_state` |
| Backend | Q5-B | `env/{env}.backend.hcl` commitados |
| CI | Q6-A | Depende de BootstrapStack + código identity + EnvConfig; YAML não cria AWS |
| Composição | Q7-A | Plana e desacoplada; IdentityPlatform = rótulo do apply de identidade |

## Componentes

Ver `components.md`.

## Interfaces

Ver `component-methods.md`.

## Serviços

Ver `services.md`. Bootstrap uma vez; deploy contínuo. Não fundir.

## Dependências

Ver `component-dependency.md`.

## Rastreio requisitos

| RF | Onde |
|----|------|
| RF-ME1 | EnvConfig + validation no identity root |
| RF-ME2 / Q5-B | `backend.hcl` + init |
| RF-ME3 | BootstrapStack / BootstrapService |
| RF-ME4 / RF-ME7 | CiPipelines |
| RF-ME5 | `run(env)` + var-file CI vs terraform.tfvars local |
| RF-ME6 | EnvConfig tfvars |
| POC v1 RF1–RF7 | Glue / Analytics / OutputContract |

## Conformidade com extensões

| Extensão | Status | Justificativa |
|----------|--------|---------------|
| Security Baseline | N/A | Desabilitada |
| Resiliency Baseline | N/A | Desabilitada |
| Property-Based Testing | N/A | Desabilitada |
