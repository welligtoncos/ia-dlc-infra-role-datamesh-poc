# Domain Entities — u1-identity-iam

## IdentityPlatform

Agregado raiz. Contém duas identidades, o contrato, o perímetro e os parâmetros. Um ciclo de vida: provisionar / expor contrato / destruir.

## GlueIdentity

| Atributo | Descrição |
|----------|-----------|
| Nome | `{prefix}-{env}-glue-role` |
| Trust | Serviço Glue + conta origem = conta da POC |
| Perímetro S3 | R/W/list/multipart em sor, sot, spec; sem delete |
| Catálogo | Leitura; mutations só de partitions |
| LF | GetDataAccess (exceção justificada) |
| Logs | Execução Glue (prefixo preferencial `/aws-glue/`) |
| ARN | Saída para o contrato |

## AnalyticsIdentity

| Atributo | Descrição |
|----------|-----------|
| Nome | `{prefix}-{env}-analytics-role` |
| Trust | Conjunto `PrincipalRef` |
| Perímetro S3 camadas | List/read only |
| Resultados Athena | R/W no bucket de resultados |
| Athena | Workgroup `athena_workgroup` |
| LF | GetDataAccess (exceção justificada) |
| ARN | Saída para o contrato |

## PrincipalRef

ARN de IAM user ou role da **mesma conta**. Lista não vazia. Usado só na trust da AnalyticsIdentity.

## DataPerimeter

| Campo | Uso |
|-------|-----|
| `sor_bucket`, `sot_bucket`, `spec_bucket` | Nomes; existência opcional no provisionamento |
| `athena_results_bucket` | Escrita da Analytics |
| `athena_workgroup` | Escopo das queries |

## OutputContract

| Campo | Cardinalidade |
|-------|----------------|
| glue_identity_arn | 1 |
| analytics_identity_arn | 1 |
| access_identity_arn | 0 (sempre nulo nesta POC) |

## Relacionamentos

```
IdentityPlatform 1 -- 1 GlueIdentity
IdentityPlatform 1 -- 1 AnalyticsIdentity
IdentityPlatform 1 -- 1 OutputContract
IdentityPlatform 1 -- 1 DataPerimeter
AnalyticsIdentity 1 -- N PrincipalRef
OutputContract le GlueIdentity e AnalyticsIdentity
GlueIdentity nao referencia AnalyticsIdentity
```

## Fora do domínio desta unidade

- Glue Job, databases, tables (schema), buckets, workgroup como **recursos criados aqui**
- Role de Acesso
- Frontend
