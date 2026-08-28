# Infrastructure Design Plan — u1-identity-iam

**Estágio**: CONSTRUCTION — Design de Infraestrutura (planejamento)
**Unidade**: `u1-identity-iam`
**Mapear para AWS real.** Sem criar buckets, Glue Job, Athena workgroup ou role de Acesso.

Preencha cada `[Answer]:`. Artefatos em `infrastructure-design/` só após as respostas.

---

## Question 1
Ambiente de implantação?

A) AWS comercial, uma conta, região via `aws_region` (default `sa-east-1`), credenciais da default chain do provider (`AWS_PROFILE` / env / instance)

B) Igual a A, mas variável Terraform `aws_profile` obrigatória

X) Other (please describe after [Answer]: tag below)

[Answer]:  A

---

## Question 2
Compute / serviço de identidade nesta unidade?

A) Só IAM: `aws_iam_role` + **customer managed** `aws_iam_policy` + attachment por identidade (sem EC2/Lambda/ECS, sem instance profile)

B) Só IAM com **inline** `aws_iam_role_policy` (sem policy gerenciada pelo cliente)

C) IAM + instance profile para EC2 futuro (fora do PRD)

X) Other (please describe after [Answer]: tag below)

[Answer]:A

---

## Question 3
Armazenamento criado por esta unidade?

A) Nenhum — não cria S3, Glue Database, Athena workgroup nem log group obrigatório; só referencia nomes nas policies

B) Esta unidade cria o bucket de resultados Athena (contraria RF/US-4)

X) Other (please describe after [Answer]: tag below)

[Answer]:A

---

## Question 4
Mensageria / eventos?

A) Nenhum SQS, SNS, EventBridge, Kinesis

B) EventBridge rule na criação das roles (observabilidade extra, fora do NFR)

X) Other (please describe after [Answer]: tag below)

[Answer]:A

---

## Question 5
Rede?

A) Sem VPC, security group, NLB, API Gateway ou VPC endpoint; chamadas IAM/S3/Glue/Athena pela API pública da AWS

B) Restringir assume da Glue a um VPC endpoint (complexo demais para a POC)

X) Other (please describe after [Answer]: tag below)

[Answer]:A

---

## Question 6
Monitoramento / logs?

A) Sem dashboards/alarmes; a GlueIdentity **pode** `logs:CreateLogGroup` / `CreateLogStream` / `PutLogEvents` no prefixo `/aws-glue/*` (recurso não é criado aqui)

B) Esta unidade cria um `aws_cloudwatch_log_group` `/aws-glue/...` para escopar melhor o Resource

X) Other (please describe after [Answer]: tag below)

[Answer]:A

---

## Question 7
Infraestrutura compartilhada com o Projeto 2?

A) Só documentar no design desta unidade: mesma conta/região/nomes de buckets e workgroup; **não** criar `shared-infrastructure.md` separado (Projeto 2 ainda não está neste repo)

B) Criar `aidlc-docs/construction/shared-infrastructure.md` com o contrato de nomes (`project_prefix`, buckets, `athena_workgroup`) para o Projeto 2

X) Other (please describe after [Answer]: tag below)

[Answer]:B

---

## Checklist de execução (após respostas)

- [x] Gerar `infrastructure-design.md` (mapeamento de serviços AWS)
- [x] Gerar `deployment-architecture.md` (apply local, uma conta)
- [x] Gerar `shared-infrastructure.md` **somente se** Q7 = B
- [x] Atualizar checkboxes e `aidlc-state.md`

---

## Regras

- Tags: `Project`, `Environment`, `ManagedBy=terraform`
- Path ARNs S3: bucket + `/*`
- Trust Glue: `glue.amazonaws.com` + `aws:SourceAccount`
- `access_role_arn` output = null (sem resource)
