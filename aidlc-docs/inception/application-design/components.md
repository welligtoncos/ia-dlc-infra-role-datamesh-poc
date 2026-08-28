# Components — InfraRoles Mini

Limites aprovados (Q1-B): **três componentes**. Bootstrap (versions, provider, variáveis, tags, backend local) é **suporte do root**, não componente.

---

## GlueIdentity

| Campo | Valor |
|-------|--------|
| Propósito | Execution role para Glue Job/Crawler da POC |
| Responsabilidades | Trust apenas para o serviço Glue; permissões de execução nas camadas `sor`/`sot`/`spec`, catálogo de execução, `GetDataAccess`, logs; nome via `project_prefix` + `environment` |
| Fora | Criar jobs/crawlers/databases; criar buckets; role de Acesso |
| Interface | Entrada: prefixo, environment, nomes dos buckets das camadas. Saída: `role_arn` |
| Histórias | US-1 (persona-dona P1; Glue Job só em aceite) |

---

## AnalyticsIdentity

| Campo | Valor |
|-------|--------|
| Propósito | Role de leitura governada para consulta Athena |
| Responsabilidades | Trust para ARNs em `analytics_principal_arns`; leitura das camadas e catálogo; Athena; R/W só no bucket de resultados |
| Fora | Escrita nas camadas; federação SSO; dependência IAM da GlueIdentity |
| Interface | Entrada: prefixo, environment, buckets das camadas, `athena_results_bucket`, `analytics_principal_arns`. Saída: `role_arn` |
| Histórias | US-2 (persona-dona P2) |

---

## OutputContract

| Campo | Valor |
|-------|--------|
| Propósito | Contrato estável de ARNs para o Projeto 2 |
| Responsabilidades | Expor `glue_role_arn`, `analytics_role_arn`; expor `access_role_arn` como `null` (constante; sem resource de Acesso) |
| Fora | Criar roles; validação `simulate-principal-policy` |
| Interface | Entrada: ARNs das duas identidades. Saída: os três outputs Terraform |
| Histórias | US-3 |

---

## Não-componentes (explícito)

| Item | Tratamento |
|------|------------|
| Terraform bootstrap | Suporte do serviço `IdentityPlatform` (US-4 parametrização) |
| IdentityVerification | Não existe; US-5 é Build and Test |
| Role de Acesso | Fora de escopo; só o null no contrato |
| Glue Job, Não-consumidor, Projeto 2 | Atores de aceite / consumidor, não componentes |
