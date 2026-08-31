# Infrastructure Design Plan — u3-identity-ci

**Estágio**: CONSTRUCTION — Design de Infraestrutura (planejamento)
**Unidade**: `u3-identity-ci`
**Mapear para GitHub Actions + AWS já criado na U2.** Esta unidade **não** cria bucket/OIDC/deploy role. Não reescreve glue.tf/analytics.tf.

Preencha cada `[Answer]:`. Artefatos em `infrastructure-design/` só após as respostas.

---

## Question 1
Ambiente de implantação?

A) GitHub.com Actions (não GHES). Cada workflow assume a deploy role **da conta daquele env** via OIDC (`role-to-assume` = var `AWS_ROLE_ARN` do GitHub Environment `dev`|`hom`|`prod`). Região: var `AWS_REGION` (default `sa-east-1`). **Local:** default credential chain **admin da mesma conta**; `provider.tf` **sem** `assume_role`. Primeiro `init` remoto: `terraform init -backend-config=env/{env}.backend.hcl` (migrate se já houver state local)

B) Igual a A, mas o root de identidade usa `assume_role` da deploy role também no apply local

X) Other (please describe after [Answer]: tag below)

[Answer]:A — GitHub.com Actions com OIDC, local com default chain admin sem assume_role. O provider do root de identidade não precisa de assume_role (B) porque localmente o admin já tem permissão direta, e no CI quem assume é o configure-aws-credentials antes do Terraform rodar — o provider recebe as credenciais temporárias via env vars, não via assume_role no bloco provider. Manter o provider limpo.

---

## Question 2
Compute nesta unidade?

A) Nenhum EC2/Lambda/CodeBuild. Compute = runner `ubuntu-latest`. Actions pinadas por major: `actions/checkout@v4`, `aws-actions/configure-aws-credentials@v4`, `hashicorp/setup-terraform@v3` (Terraform **1.9.8** no setup)

B) Pin de actions por commit SHA (mais rígido)

C) AWS CodeBuild / CodePipeline no lugar do GitHub-hosted (contraria NFR)

X) Other (please describe after [Answer]: tag below)

[Answer]:A — pin por major (@v4, @v3). Pin por SHA (B) é mais rígido mas menos legível e mais trabalhoso de atualizar — para POC, major é o equilíbrio certo. Terraform 1.9.8 no setup, coerente com o NFR Q5-B.

---

## Question 3
Armazenamento (state da identidade + artifact de plan)?

A) Backend S3 **já existente (U2)**. `backend "s3" {}` vazio no root. `env/{env}.backend.hcl`: `bucket`, `dynamodb_table`, `region`, `encrypt = true`, **key** = `{project_prefix}/{environment}/identity.tfstate` (ex.: `datamesh-poc/dev/identity.tfstate`). Artifact `tfplan` **só** no GitHub Actions (retention 1 dia) — **não** gravar o plan no bucket de state

B) Key livre por variável sem convenção de path

C) Guardar `tfplan` no bucket S3 de state (mistura plan CI com state)

X) Other (please describe after [Answer]: tag below)

[Answer]:A — backend "s3" {} vazio no root, env/{env}.backend.hcl com a key por convenção (datamesh-poc/{env}/identity.tfstate). Artifact tfplan só no GitHub Actions (retention 1 dia, nunca no S3). Key livre (B) perde rastreabilidade; plan no S3 (C) mistura artefato efêmero com state persistente.

---

## Question 4
Mensageria / eventos?

A) Nenhum SQS, SNS, EventBridge, Kinesis. Gatilho = `push` / `workflow_dispatch` do GitHub

B) EventBridge na conta AWS quando o apply termina (fora do NFR)

X) Other (please describe after [Answer]: tag below)

[Answer]:A — nenhuma mensageria. Gatilho é push/dispatch do GitHub. EventBridge (B) seria observabilidade fora do NFR.

---

## Question 5
Rede?

A) Sem VPC/SG/NLB. Runner GitHub → APIs públicas AWS (STS, IAM, S3, DynamoDB) + `token.actions.githubusercontent.com` (já na U2)

B) VPC endpoints / runner em VPC (overkill)

X) Other (please describe after [Answer]: tag below)

[Answer]:A — sem rede. Runner → APIs públicas. Mesma decisão de todas as unidades anteriores.

---

## Question 6
Monitoramento criado aqui?

A) Nenhum CloudWatch/alarme. Observabilidade = logs do GitHub Actions + saída do `terraform plan` / simulate

B) CloudWatch alarm / metric filter nesta unidade

X) Other (please describe after [Answer]: tag below)

[Answer]:A — nenhum CloudWatch. Logs do GitHub Actions + saída do plan/simulate são a observabilidade. Consistente com o NFR.

---

## Question 7
Infraestrutura compartilhada (emendar `shared-infrastructure.md`)?

A) Emendar com: nomes dos workflows/callers; GitHub Environments `dev`/`hom`/`prod`; vars `AWS_ROLE_ARN` e `AWS_REGION`; key de state `{prefix}/{env}/identity.tfstate`; ordem bootstrap → Environments → primeiro init (migrate se preciso) → pipeline

B) Não emendar; contrato só no README da U3

X) Other (please describe after [Answer]: tag below)

[Answer]:A — emendar o shared-infrastructure.md. Os nomes dos workflows, as vars do GitHub Environment (AWS_ROLE_ARN, AWS_REGION), a key de state e a ordem de setup são contrato operacional entre quem faz o bootstrap, quem configura o GitHub e quem roda a pipeline. Deixar só no README (B) espalharia essa informação — o shared-infrastructure existe para centralizar.

---

## Question 8
State local já existente (POC v1, uma conta)?

A) README: se a conta **já** foi aplicada com backend local, o engenheiro roda **uma vez** `terraform init -backend-config=env/{env}.backend.hcl -migrate-state` **com admin**, depois o CI usa o state remoto. CI **não** faz migrate. Contas nunca aplicadas: init remoto cria state vazio e o primeiro apply popula

B) Sempre discar o state local e reaplicar do zero no CI (pode recriar roles se o state local era a fonte da verdade)

X) Other (please describe after [Answer]: tag below)

[Answer]:A — migrate-state uma vez com admin, depois o CI usa o remoto. Este é o ponto mais prático do gate. A conta 082846230365 já tem um state local da POC v1 (a identidade foi provisionada com backend local). Se o CI fizer init remoto sem migrar, ele vê um state vazio e tenta recriar as roles que já existem — ou falha por conflito de nome, ou cria duplicatas. A migração (-migrate-state) transfere o state existente para o S3, e a partir daí tudo é remoto. O README precisa ser explícito: "se a conta já foi aplicada com backend local, migre o state antes do primeiro run de CI". B (descartar e reaplicar) é perigoso: pode recriar roles com ARNs diferentes, quebrando o contrato com o Projeto 2.

---

## Checklist de execução (após respostas)

- [x] Gerar `infrastructure-design.md`
- [x] Gerar `deployment-architecture.md`
- [x] Emendar `shared-infrastructure.md` **somente se** Q7 = A
- [x] Atualizar checkboxes e `aidlc-state.md`

---

## Regras

- Não criar S3/DDB/OIDC/role (U2)
- Não criar Glue/Analytics resources novos
- Nomes GitHub Environment = `dev` | `hom` | `prod` (iguais ao claim OIDC)
- Destroy da identidade: local/manual, não CI
