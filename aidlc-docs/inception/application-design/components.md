# Components — Incremento multi-env

POC v1 (inalterada): `GlueIdentity`, `AnalyticsIdentity`, `OutputContract`. Ver seções abaixo e `application-design-plan-poc-v1.md`.

Incremento (Q1-A): três componentes **novos**. O “bootstrap” da POC v1 (versions/provider/tags **dentro do root de identidade**) continua **suporte** desse root — não confundir com `BootstrapStack`.

---

## BootstrapStack (novo)

| Campo | Valor |
|-------|--------|
| Propósito | Preparar a conta para state remoto e deploy por OIDC |
| Responsabilidades | Um apply local (admin) por conta: bucket S3 de state, DynamoDB lock, OIDC provider GitHub, IAM deploy role |
| Fora | Roles Glue/Analytics; workflows GitHub; criar contas AWS; apply no CI (ovo-e-galinha) |
| Interface | `apply_once` / `destroy_local` (state **local**, gitignored) |
| Serviço | `BootstrapService` |

---

## EnvConfig (novo)

| Campo | Valor |
|-------|--------|
| Propósito | Superfície de variação por ambiente (o ponto central do incremento) |
| Responsabilidades | `env/{dev,hom,prod}.tfvars` e `env/{dev,hom,prod}.backend.hcl` **commitados** (placeholders ok); valores que o identity apply e o CI consomem |
| Fora | Resources AWS; secrets de longo prazo |
| Interface | Arquivos por `environment`; CI usa `-var-file` + `-backend-config`; local copia tfvars → `terraform.tfvars` |
| Serviço | Consumido por `DeployService` e pelo apply local do identity |

---

## CiPipelines (novo)

| Campo | Valor |
|-------|--------|
| Propósito | Aplicar o root de identidade na conta do ambiente, de forma isolada |
| Responsabilidades | Três workflows (`deploy-dev` / `deploy-hom` / `deploy-prod`); OIDC; `run(env)` = fmt → validate → plan → apply → `simulate-principal-policy.sh`; aprovação GitHub Environment em hom/prod |
| Fora | Declarar resources AWS; `destroy`; ownership do script de simulate (Build/Test); criar a branch `hom` (setup README) |
| Interface | `run(env)` onde `env` ∈ {dev, hom, prod} |
| Serviço | `DeployService` |

---

## GlueIdentity / AnalyticsIdentity / OutputContract (POC v1)

Inalterados em propósito. Passam a ser aplicados com backend remoto e `environment` ∈ {dev, hom, prod}. Check same-account permanece **por conta**.

| Componente | Propósito |
|------------|-----------|
| GlueIdentity | Execution role Glue |
| AnalyticsIdentity | Role de leitura Athena/camadas |
| OutputContract | `glue_role_arn`, `analytics_role_arn`, `access_role_arn=null` |

---

## Não-componentes (explícito)

| Item | Tratamento |
|------|------------|
| IdentityPlatform | Rótulo do apply do **root de identidade** (POC v1 Q7-A); não é fachada e não une bootstrap+identity |
| MultiEnvPlatform | Rejeitado (Q7-B) |
| IdentityVerification | US-5 / simulate: Build and Test; CiPipelines **invoca** o `.sh` |
| Versions/provider do identity root | Suporte do IdentityPlatform, não BootstrapStack |
| Projeto 2, Glue Job, Analista | Atores / consumidores |
