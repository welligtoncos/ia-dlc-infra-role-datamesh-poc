# Functional Design Plan — u1-identity-iam

**Estágio**: CONSTRUCTION — Design Funcional (planejamento)
**Unidade**: `u1-identity-iam`
**Agnóstico a tecnologia**: regras de identidade e perímetro; sem resources AWS concretos (isso é Infrastructure Design / Code)

Preencha cada `[Answer]:`. Os artefatos em `aidlc-docs/construction/u1-identity-iam/functional-design/` só são gerados depois das respostas.

Frontend/UI: **N/A** (sem interface). Sem pergunta de UI.

---

## Question 1
No catálogo Glue, o que a execution role pode fazer além de “não criar job/crawler/database”?

A) Só leitura do catálogo (Get/List de databases, tables, partitions) — tabelas já existem

B) Leitura + criar/atualizar tables e partitions (ETL materializa esquema), sem criar/apagar databases, jobs ou crawlers

C) Qualquer operação de catálogo exceto jobs, crawlers e databases

X) Other (please describe after [Answer]: tag below)

[Answer]:X	Glue: lê catálogo + só partitions (schema é IaC-owned)

---

## Question 2
Quais operações de objeto nas camadas `sor` / `sot` / `spec` a GlueIdentity pode fazer?

A) Ler, gravar, listar e apagar objetos (inclui multipart)

B) Ler, gravar e listar — sem apagar

C) Ler e listar apenas (escrita só via outro caminho — fora do RF2 atual)

X) Other (please describe after [Answer]: tag below)

[Answer]:B	Glue S3: read/write/list + multipart, sem delete

---

## Question 3
Quais operações nas mesmas camadas a AnalyticsIdentity pode fazer?

A) Somente listar e ler objetos (sem Put/Delete)

B) Listar, ler e ler versões — ainda sem escrita

C) Leitura das camadas + escrita se o prefixo for `tmp/` (exceção)

X) Other (please describe after [Answer]: tag below)

[Answer]:A	Analytics S3: só list/read nas camadas

---

## Question 4
Como delimitar o uso de Athena pela AnalyticsIdentity?

A) Executar, acompanhar e obter resultado de queries, sem workgroup parametrizado (escopo amplo justificado no RNF3 se preciso)

B) Igual a A, restrito a um workgroup cujo nome é variável (`athena_workgroup`)

C) Athena irrestrito na conta

X) Other (please describe after [Answer]: tag below)

[Answer]:B	Athena escopado a athena_workgroup

---

## Question 5
Quando o provisionamento deve **falhar** por regra de negócio (antes ou no apply)?

A) Somente se `analytics_principal_arns` estiver vazia

B) Lista vazia **ou** qualquer ARN que não seja IAM user/role da mesma conta (formato inválido)

C) Não validar lista além de “não vazia”; ARNs inválidos falham na API da nuvem

X) Other (please describe after [Answer]: tag below)

[Answer]:B	Fail-fast: lista vazia ou ARN inválido/fora da conta

---

## Question 6
Qual o padrão de nome de negócio das duas roles?

A) `{project_prefix}-{environment}-glue-role` e `{project_prefix}-{environment}-analytics-role`

B) `{project_prefix}-{environment}-glue` e `{project_prefix}-{environment}-analytics`

C) `{project_prefix}_{environment}_glue_role` (underscore)

X) Other (please describe after [Answer]: tag below)

[Answer]:A	{prefix}-{env}-glue-role / -analytics-role

---

## Question 7
A trust da GlueIdentity admite só o serviço Glue, ou também restrição de conta origem?

A) Somente serviço Glue (principal de serviço)

B) Serviço Glue **e** condição de que a conta origem seja a conta da POC

C) Serviço Glue + VPC/endpoint (desnecessário nesta POC)

X) Other (please describe after [Answer]: tag below)

[Answer]:B	Trust Glue + aws:SourceAccount (anti confused-deputy)

---

## Question 8
As camadas de dados podem ainda **não existir** quando a identidade for provisionada?

A) Sim — o perímetro é definido pelos **nomes** dos buckets; a identidade pode existir antes da malha (Projeto 2)

B) Não — o provisionamento deve falhar se os buckets não existirem

X) Other (please describe after [Answer]: tag below)

[Answer]:A	Identidade existe antes das camadas (perímetro por nome)

---

## Question 9
`lakeformation:GetDataAccess` e logs de execução Glue: como tratar o perímetro “estreito demais”?

A) Seguir as exceções já listadas no RNF3 (GetDataAccess e logs com justificativa; preferir prefixo de log `/aws-glue/` quando possível)

B) Tentar escopar GetDataAccess a um resource ARN mesmo que a API ignore (documentar falha se não aplicar)

C) Omitir GetDataAccess nesta POC (quebra RF2)

X) Other (please describe after [Answer]: tag below)

[Answer]:A	Exceções RNF3 para GetDataAccess e logs

---

## Checklist de execução (após respostas)

- [x] Carregar unidade, stories e este plano
- [x] Gerar `business-logic-model.md` (fluxos apply/assume/output/destroy)
- [x] Gerar `business-rules.md` (trust, perímetro, validações, deny)
- [x] Gerar `domain-entities.md` (Role, Trust, Perímetro, Principal, Contrato)
- [x] Não gerar frontend-components.md (N/A)
- [x] Atualizar checkboxes e `aidlc-state.md`

---

## Regras

- Sem nomes de resource Terraform
- Extensões Security / Resiliency / PBT: N/A
