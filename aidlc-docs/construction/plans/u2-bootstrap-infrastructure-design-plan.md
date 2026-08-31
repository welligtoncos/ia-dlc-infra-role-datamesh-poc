# Infrastructure Design Plan — u2-bootstrap

**Estágio**: CONSTRUCTION — Design de Infraestrutura (planejamento)
**Unidade**: `u2-bootstrap`
**Mapear para AWS real.** Apply local (admin), uma vez por conta. Não cria Glue/Analytics nem workflows.

Preencha cada `[Answer]:`. Artefatos em `infrastructure-design/` só após as respostas.

---

## Question 1
Ambiente de implantação do bootstrap?

A) AWS comercial; **uma conta por apply**; região `var.aws_region` (default `sa-east-1`); credenciais admin da default chain; **sem** `assume_role` no provider (é o primeiro apply da conta)

B) Igual a A + variável `aws_profile` obrigatória

X) Other (please describe after [Answer]: tag below)

[Answer]: A — default chain, sem aws_profile obrigatório, sem assume_role. É o primeiro apply da conta — não existe role para assumir ainda (ovo-e-galinha). O admin autentica direto.

---

## Question 2
Compute nesta unidade?

A) Nenhum EC2/Lambda/ECS. Só IAM: OIDC provider + **uma** `aws_iam_role` de deploy (customer managed policy) por conta

B) A + instance profile (fora de escopo)

X) Other (please describe after [Answer]: tag below)

[Answer]: A — nenhum compute. Só IAM: OIDC provider + uma deploy role com customer managed policy. Coerente com o escopo do bootstrap.

---

## Question 3
Armazenamento (backend da U3)?

A) `aws_s3_bucket` (versioning, BPA, SSE-S3, sem force_destroy, prevent_destroy) + `aws_dynamodb_table` (PAY_PER_REQUEST, hash key `LockID`, PITR, prevent_destroy). Nomes: `{project_prefix}-{environment}-tfstate` e `{project_prefix}-{environment}-tf-lock` (S3 precisa ser globalmente único — se colidir, variável override)

B) Nomes 100% livres (só variáveis, sem convenção)

X) Other (please describe after [Answer]: tag below)

[Answer]: A — nomes por convenção ({prefix}-{env}-tfstate, {prefix}-{env}-tf-lock) com override se o nome S3 colidir (globalmente único). prevent_destroy + sem force_destroy + SSE-S3 + PITR. Tudo alinhado ao NFR Design. Nomes 100% livres (B) perde a rastreabilidade — a convenção amarra com o contrato

---

## Question 4
Mensageria / eventos?

A) Nenhum SQS, SNS, EventBridge, Kinesis

B) EventBridge na criação do bucket (fora do NFR)

X) Other (please describe after [Answer]: tag below)

[Answer]: A — nenhuma mensageria. Bootstrap é one-shot sem evento.

---

## Question 5
Rede?

A) Sem VPC/SG/NLB. APIs públicas AWS + OIDC `https://token.actions.githubusercontent.com`

B) VPC endpoints para S3/STS (overkill)

X) Other (please describe after [Answer]: tag below)

[Answer]: A — sem rede. APIs públicas + OIDC endpoint público do GitHub. VPC endpoints (B) é overkill para um apply que roda uma vez.

---

## Question 6
Monitoramento criado aqui?

A) Nenhum dashboard/alarme/log group. Observabilidade = CLI + README

B) CloudWatch alarm no DynamoDB (contraria NFR)

X) Other (please describe after [Answer]: tag below)

[Answer]: A — nenhum monitoramento. CLI + README. Coerente com o NFR.

---

## Question 7
OIDC provider se a conta **já** tiver um provider GitHub?

A) `aws_iam_openid_connect_provider` gerenciado por este root; se já existir, o engenheiro importa (`terraform import`) ou apaga o duplicado — documentar no README

B) `data` source do provider existente + só criar a role (não gerenciar o OIDC neste Terraform)

X) Other (please describe after [Answer]: tag below)

[Answer]: A — gerenciar o OIDC provider neste root. Se já existir na conta, o engenheiro importa ou resolve o conflito. Documentar no README. A opção B (data source) parece mais segura, mas tem um problema prático: se o provider não existir, o data falha no plan e você não consegue criar nem a role. O resource funciona nos dois casos (cria se não existe; importa se existe). É mais robusto para um bootstrap que roda em contas possivelmente vazias.

---

## Question 8
Infraestrutura compartilhada com U3 / Projeto 2?

A) Só outputs + README desta unidade (bucket, dynamodb, role ARN, region); **não** editar `shared-infrastructure.md` agora (U3 fará o contrato de backend)

B) Emendar `aidlc-docs/construction/shared-infrastructure.md` com a tabela backend (nomes S3/DDB, OIDC) além do contrato de buckets do Projeto 2

X) Other (please describe after [Answer]: tag below)

[Answer]: B — emendar o shared-infrastructure.md com os nomes de backend (bucket, DynamoDB, OIDC, deploy role ARN). O contrato entre unidades precisa de um único lugar de verdade. Deixar só nos outputs + README do bootstrap (A) espalha a informação — a U3 teria que caçar nomes no README do bootstrap em vez de olhar um documento de contrato. O shared-infrastructure.md já existe justamente para ser o anti-drift; adicionar o backend ali é natural e coerente.

---

## Checklist de execução (após respostas)

- [x] Gerar `infrastructure-design.md`
- [x] Gerar `deployment-architecture.md`
- [x] Emendar `shared-infrastructure.md` **somente se** Q8 = B
- [x] Atualizar checkboxes e `aidlc-state.md`

---

## Regras

- Tags: `Project`, `Environment`, `ManagedBy=terraform`
- Trust deploy: `aud` + `sub` `repo:OWNER/REPO:environment:ENV`
- `environment` ∈ {dev, hom, prod} (a conta do apply é a desse env)
- Sem YAML GitHub nesta unidade
