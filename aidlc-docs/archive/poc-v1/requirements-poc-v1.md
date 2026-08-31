# Requirements — Camada de Identidade (InfraRoles Mini) — POC v1 (arquivado)

Arquivado em 2026-08-30 ao iniciar o incremento multi-env. O documento ativo passou a ser `requirements.md`.

## Intent Analysis Summary

| Campo | Valor |
|-------|-------|
| Solicitação do usuário | Inception AI-DLC a partir do PRD de InfraRoles |
| Tipo de solicitação | Novo projeto (greenfield IaC) |
| Estimativa de escopo | Múltiplos componentes (roles Glue e Analytics, policies, outputs) |
| Estimativa de complexidade | Moderada |
| Profundidade | Padrão |
| Fonte | `prd-source.md` (PRD 1.0 POC) + respostas em `requirement-verification-questions-poc-v1.md` |

---

## 1. Visão

Provisionar, via Terraform, a camada de identidade e acesso (IAM Roles e Policies) de uma arquitetura Data Mesh pessoal em **uma única conta AWS**. Este projeto (Projeto 1) entrega os ARNs consumidos pela plataforma de dados (Projeto 2).

**Objetivos**
- **O1.** Roles versionadas e reproduzíveis via IaC.
- **O2.** Menor privilégio, escopado aos recursos da POC.
- **O3.** ARNs como contrato de integração para o Projeto 2.
- **O4.** 100% destruível/recriável (`apply` / `destroy` limpos).

**Não-objetivos**
- Multi-conta
- Roles de ECS, EventBridge ou mainframe
- Ambientes hom/prod (apenas `dev` nesta POC)
- Módulo corporativo `itau-ey4-modulo-iamsr`
- Federação SSO / IdP corporativo
- Rotação de credenciais e políticas de senha
- Criação de buckets, databases Glue, Lake Formation grants ou jobs ETL
- Role de Acesso (automação) nesta iteração — apenas o output contratual

---

## 2. Personas

- **Engenheiro de dados:** aplica e mantém o Terraform; assume a role de Analytics para validar consumo.
- **Glue Job (sistema):** assume a role de Glue para executar ETL.
- **Analista/BI (consumidor):** assume a role de Analytics para consulta via Athena.

---

## 3. Decisões fechadas (esclarecimentos)

| Tema | Decisão |
|------|---------|
| Trust da role Analytics | Lista parametrizada de ARNs (`users` e/ou `roles`) |
| Role de Acesso | Não criar agora; output `access_role_arn` = `null` |
| Região | Variável `aws_region` com default `sa-east-1` |
| Prefixo | `datamesh-poc` (parametrizado; default este valor) |
| Buckets | Este projeto **não cria** buckets; só referencia nomes em policies |
| Camadas | `sor`, `sot`, `spec` (fidelidade Itaú / DBs do Projeto 2) |
| Athena results | Variável `athena_results_bucket`; bucket criado no Projeto 2 |
| Role Glue | Somente execution role (Job/Crawler) |
| State | Backend local; state fora do git |
| Estrutura | Um arquivo por role no root module (`glue.tf`, `analytics.tf`) |
| Extensões | Security Baseline: **Não**; Resiliency: **Não**; PBT: **Não** |

---

## 4. Requisitos Funcionais

RF1–RF7 da POC v1 permanecem a base da identidade IAM. Texto completo está no histórico git desta versão e foi incorporado (com emendas multi-env) em `requirements.md`.
