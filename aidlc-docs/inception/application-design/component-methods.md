# Component Methods — InfraRoles Mini

Assinaturas de **interface** (Q2-C). Regras de policy detalhadas ficam no Design Funcional.

Dois níveis:
1. Operações do root / serviço `IdentityPlatform`
2. Entradas e saídas de cada componente

---

## IdentityPlatform (operações do root)

Não é componente (Q7-A). Operações do ciclo de vida Terraform:

| Operação | Entrada | Saída | Propósito |
|----------|---------|-------|-----------|
| `plan` | Variáveis da POC | Plano de mudança | Preview sem aplicar |
| `apply` | Variáveis da POC (lista `analytics_principal_arns` não vazia) | Estado local + recursos | Provisionar as duas identidades e o contrato |
| `output` | Estado aplicado | Três ARNs (Acesso = null) | Consumo pelo engenheiro / Projeto 2 |
| `destroy` | Estado aplicado | Conta sem recursos deste projeto | US-6; não destrói buckets do Projeto 2 |

Variáveis da POC (suporte, US-4): `project_prefix`, `environment`, `aws_region`, `sor_bucket`, `sot_bucket`, `spec_bucket`, `athena_results_bucket`, `analytics_principal_arns`.

---

## GlueIdentity

| Interface | Tipo | Descrição |
|-----------|------|-----------|
| `configure(prefix, environment, sor_bucket, sot_bucket, spec_bucket)` | entrada | Naming e perímetro S3 das camadas |
| `role_arn` | saída | ARN da execution role |

Sem operação `assume` neste componente: quem assume é o Glue Job (ator de aceite).

---

## AnalyticsIdentity

| Interface | Tipo | Descrição |
|-----------|------|-----------|
| `configure(prefix, environment, sor_bucket, sot_bucket, spec_bucket, athena_results_bucket, analytics_principal_arns)` | entrada | Naming, perímetro de leitura, resultados Athena, trust |
| `role_arn` | saída | ARN da role de Analytics |

Sem operação `assume` neste componente: P2 e Não-consumidor são atores de aceite.

---

## OutputContract

| Interface | Tipo | Descrição |
|-----------|------|-----------|
| `bind(glue_role_arn, analytics_role_arn)` | entrada | ARNs produzidos pelas identidades |
| `glue_role_arn` | saída | Pass-through |
| `analytics_role_arn` | saída | Pass-through |
| `access_role_arn` | saída | Sempre `null` nesta POC |

---

## Fora deste documento

- Matriz allow/deny por ação IAM → Design Funcional
- `simulate-principal-policy` → Build and Test (Q6-A)
