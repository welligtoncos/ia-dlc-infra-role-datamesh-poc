# Business Rules — u1-identity-iam

## BR-VAL — Validação de principais (Q5-B)

- **BR-VAL-1.** Provisionamento falha se `analytics_principal_arns` estiver vazia.
- **BR-VAL-2.** Provisionamento falha se qualquer elemento não for ARN de IAM **user** ou **role**.
- **BR-VAL-3.** Provisionamento falha se o account-id do ARN não for a conta da POC.

## BR-NAME — Nomes (Q6-A)

- **BR-NAME-1.** GlueIdentity: `{project_prefix}-{environment}-glue-role`
- **BR-NAME-2.** AnalyticsIdentity: `{project_prefix}-{environment}-analytics-role`

## BR-TRUST-G — Trust Glue (Q7-B)

- **BR-TRUST-G-1.** Só o serviço Glue pode assumir a GlueIdentity.
- **BR-TRUST-G-2.** A conta de origem da sessão deve ser a conta da POC (anti confused-deputy).
- **BR-TRUST-G-3.** Usuários e outras roles **não** assumem a GlueIdentity.

## BR-TRUST-A — Trust Analytics

- **BR-TRUST-A-1.** Só ARNs em `analytics_principal_arns` assumem a AnalyticsIdentity.
- **BR-TRUST-A-2.** ARN fora da lista (Não-consumidor) → assume negado.
- **BR-TRUST-A-3.** Serviço Glue **não** assume a AnalyticsIdentity.

## BR-GLUE-CAT — Catálogo (Q1-X)

- **BR-GLUE-CAT-1.** Schema de tables/databases é **owned por IaC** (Projeto 2 / catálogo): GlueIdentity **não** cria, altera nem apaga databases, tables, jobs ou crawlers.
- **BR-GLUE-CAT-2.** GlueIdentity **lê** databases, tables e partitions (Get/List).
- **BR-GLUE-CAT-3.** GlueIdentity **pode criar e atualizar partitions** (execução de job/crawler), sem mudar o schema da table.

## BR-GLUE-S3 — Objetos nas camadas (Q2-B)

- **BR-GLUE-S3-1.** Nas camadas `sor`, `sot`, `spec`: ler, gravar, listar e multipart.
- **BR-GLUE-S3-2.** **Sem delete** de objetos nessas camadas.
- **BR-GLUE-S3-3.** Fora desses nomes de bucket → negado.

## BR-AN-S3 — Analytics nas camadas (Q3-A)

- **BR-AN-S3-1.** Só listar e ler objetos em `sor`, `sot`, `spec`.
- **BR-AN-S3-2.** Sem Put, Delete ou multipart nas camadas.
- **BR-AN-S3-3.** Leitura e escrita **somente** no bucket de resultados Athena.

## BR-ATH — Athena (Q4-B)

- **BR-ATH-1.** AnalyticsIdentity executa, acompanha, interrompe e obtém resultados de queries **apenas** no workgroup cujo nome é `athena_workgroup` (nova entrada de parametrização).
- **BR-ATH-2.** Queries em outro workgroup → negadas.

## BR-LF-LOG — Exceções de perímetro (Q9-A)

- **BR-LF-1.** `GetDataAccess` no Lake Formation é permitido com perímetro amplo **justificado** (API não escopável por bucket) — RNF3.
- **BR-LOG-1.** Logs de execução Glue: preferir prefixo `/aws-glue/`; se o destino ainda não existir, exceção RNF3 documentada.

## BR-TIME — Ordem com o Projeto 2 (Q8-A)

- **BR-TIME-1.** Identidade **pode** ser provisionada antes das camadas existirem; o perímetro usa **nomes** de bucket, não a existência do bucket.
- **BR-TIME-2.** Destroy desta unidade **não** remove buckets nem workgroup do Projeto 2.

## BR-OUT — Contrato

- **BR-OUT-1.** Contrato publica ARN Glue, ARN Analytics e `access_role_arn` **nulo** (não string vazia).
- **BR-OUT-2.** Não existe identidade de Acesso nesta unidade.

## BR-DENY — Menor privilégio (US-5)

- **BR-DENY-1.** Qualquer bucket cujo nome não esteja no perímetro → deny (ou ausência de allow) nas simulações.
- **BR-DENY-2.** Não-consumidor não assume Analytics e não consulta as camadas com essa role.
