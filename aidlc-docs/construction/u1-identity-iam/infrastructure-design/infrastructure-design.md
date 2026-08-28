# Infrastructure Design — u1-identity-iam

## Provedor e ambiente

| Item | Escolha |
|------|---------|
| Cloud | AWS comercial |
| Contas | Uma (pessoal / POC) |
| Região | `var.aws_region` default `sa-east-1` |
| Auth provider | Default credential chain (sem `var.aws_profile`) |
| Terraform | `>= 1.7.5`, `hashicorp/aws ~> 5.0`, lockfile commitado |
| Backend | Local |

## Mapeamento lógico → AWS

| Lógico | AWS | Notas |
|--------|-----|--------|
| GlueIdentity | `aws_iam_role` + `aws_iam_policy` + `aws_iam_role_policy_attachment` | Customer managed; sem inline |
| AnalyticsIdentity | idem | Trust: lista `analytics_principal_arns` |
| OutputContract | `output` blocks | `access_role_arn = null`; sem resource de Acesso |
| DataPerimeter | ARNs nas policies | Buckets/workgroup **não** criados aqui |
| PrincipalRef | Trust policy JSON | Validação: não vazio; user/role; mesma conta (`data.aws_caller_identity`) |
| GitIgnore / ExampleTfvars / Lockfile / Readme / SimulateScript | arquivos no repo | Não são recursos AWS |

## Não provisionar nesta unidade

EC2, Lambda, ECS, instance profile, S3 bucket, Glue DB/Job, Athena workgroup, log group, SQS/SNS/EventBridge, VPC, SG, endpoint, dashboards.

## IAM — detalhe

**Glue role**
- Nome: `{prefix}-{env}-glue-role`
- Trust: `glue.amazonaws.com` + `sts:AssumeRole` + `aws:SourceAccount` = account atual
- Policy (allow-only): S3 Get/Put/List/AbortMultipart/ListMultipartUploadParts em `sor`/`sot`/`spec` (bucket e `/*`); **sem DeleteObject**
- Glue catalog Get/List; `glue:CreatePartition` / `UpdatePartition` / `BatchCreatePartition` (sem CreateTable/Database/Job/Crawler)
- `lakeformation:GetDataAccess` Resource `*` justificado
- `logs:CreateLogGroup`, `CreateLogStream`, `PutLogEvents` em `arn:aws:logs:{region}:{account}:log-group:/aws-glue/*`

**Analytics role**
- Nome: `{prefix}-{env}-analytics-role`
- Trust: cada ARN da lista (user ou role)
- S3 Get/List nas camadas; Get/Put/List no `athena_results_bucket`
- Glue Get/List (sem Create/Update/Delete de schema)
- Athena Start/Get/Stop/GetQueryResults escopado ao workgroup `arn:aws:athena:{region}:{account}:workgroup/{athena_workgroup}` (+ ações de workgroup Get se necessário)
- `lakeformation:GetDataAccess` `*` justificado

**Tags** em role e policy: `Project`, `Environment`, `ManagedBy=terraform`

## S3 ARNs

```
arn:aws:s3:::${bucket}
arn:aws:s3:::${bucket}/*
```

## Outputs

| Output | Origem |
|--------|--------|
| `glue_role_arn` | Glue role |
| `analytics_role_arn` | Analytics role |
| `access_role_arn` | `null` |
