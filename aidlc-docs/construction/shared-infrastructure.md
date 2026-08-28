# Shared Infrastructure — contrato com o Projeto 2

Este repositório (Projeto 1) **não cria** a malha de dados. O Projeto 2 deve usar os **mesmos nomes** e a **mesma conta/região**.

## Conta e região

| Item | Contrato |
|------|----------|
| Conta | Mesma conta AWS da POC |
| Região | `aws_region` (default `sa-east-1`) |
| Prefixo | `project_prefix` (default `datamesh-poc`) |
| Ambiente | `environment` (default `dev`) |

## Nomes que o Projeto 2 deve criar / possuir

| Recurso | Variável neste projeto | Uso |
|---------|------------------------|-----|
| Bucket camada SOR | `sor_bucket` | Glue R/W/list; Analytics list/read |
| Bucket camada SOT | `sot_bucket` | idem |
| Bucket camada SPEC | `spec_bucket` | idem |
| Bucket resultados Athena | `athena_results_bucket` | Analytics R/W |
| Workgroup Athena | `athena_workgroup` | Analytics query |

Schema Glue (databases/tables) é **IaC-owned no Projeto 2**. Jobs/crawlers assumem `glue_role_arn`.

## O que o Projeto 2 consome deste apply

| Output | Significado |
|--------|-------------|
| `glue_role_arn` | Execution role Glue |
| `analytics_role_arn` | Role de leitura governada |
| `access_role_arn` | Sempre `null` nesta POC |

## Ordem

Identidade **pode** ser aplicada **antes** dos buckets/workgroup existirem. O Projeto 2 não deve destruir as roles; o destroy do Projeto 1 não deve destruir buckets.
