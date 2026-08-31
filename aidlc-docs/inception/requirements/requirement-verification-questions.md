# Requirements Clarification Questions — Incremento multi-env

Responda cada pergunta preenchendo a letra após a tag `[Answer]:`.
Se nenhuma opção corresponder, escolha a última opção (Other / Outro) e descreva a preferência.

**Já fechado neste incremento (não precisa repetir):**

- Três **contas AWS fixas** (já existentes ou criadas fora deste repo — este Terraform **não** cria contas Organizations).
- Uma conta por ambiente: **dev**, **hom**, **prod**.
- Uma **pipeline por ambiente** para aplicar este Terraform (roles IAM Glue + Analytics) na conta correspondente.
- Mesmo código; cada pipeline sobe só o seu ambiente.

Respostas da POC v1 (IAM em si): arquivo `requirement-verification-questions-poc-v1.md` + `requirements.md`.

---

## Question 1
Onde as pipelines devem rodar?

A) GitHub Actions (três workflows, um por ambiente)

B) GitLab CI (três pipelines/jobs, um por ambiente)

C) AWS CodePipeline (um pipeline por conta/ambiente)

D) Azure DevOps (três pipelines)

X) Other (please describe after [Answer]: tag below)

[Answer]: A — GitHub Actions. Você já está no ecossistema Git/GitHub, três workflows (um por env) é o mais direto. CodePipeline (C) seria nativo AWS mas é mais pesado de montar; GitLab/Azure não são o seu caso.

---

## Question 2
Como cada pipeline autentica na conta AWS do seu ambiente?

A) OIDC (GitHub/GitLab → IAM role na conta do ambiente; sem access keys no CI)

B) Access keys IAM guardadas como secret do CI (uma dupla por ambiente)

C) Role de deploy já existente em cada conta; o CI assume essa role (ARN informado por variável)

X) Other (please describe after [Answer]: tag below)

[Answer]: A — OIDC. Sem access keys no CI — é o padrão recomendado pela AWS e elimina o risco de credenciais de longo prazo em secrets. Cada conta tem uma role de deploy que confia no provedor OIDC do GitHub.

---

## Question 3
Onde fica o state do Terraform de cada ambiente?

A) Backend S3 + lock DynamoDB **dentro da própria conta** do ambiente (dev, hom e prod cada um com o seu state)

B) Backend S3 + lock DynamoDB em **uma conta de bootstrap/shared** (três keys de state: `dev/`, `hom/`, `prod/`)

C) State remoto gerenciado (Terraform Cloud / HCP Terraform), um workspace por ambiente

X) Other (please describe after [Answer]: tag below)

[Answer]: S3+DynamoDB dentro da própria conta de cada ambiente. Cada conta dona do seu state. Evita dependência cruzada (prod não depende de uma conta "shared" para acessar seu próprio state) e é mais simples de raciocinar sobre permissões.

---

## Question 4
Este repositório deve **criar** o bucket S3 e a tabela DynamoDB do backend, ou eles já existem / serão criados na mão?

A) Já existem (ou serão criados manualmente); o código só declara o `backend` apontando para eles

B) Incluir um bootstrap mínimo neste repo (ex.: `bootstrap/` aplicado uma vez por conta) que cria bucket + DynamoDB

C) Pipeline cria o backend na primeira execução (script + `backend` parcial)

X) Other (please describe after [Answer]: tag below)

[Answer]: B — bootstrap mínimo neste repo (bootstrap/) aplicado uma vez por conta. Cria o bucket + DynamoDB + a role OIDC de deploy. Reproduzível e versionado, sem depender de "alguém criou na mão e esqueceu como".

---

## Question 5
Como cada pipeline é disparada?

A) Independente: cada ambiente tem o seu gatilho (ex.: branch `dev` / `hom` / `main`, ou workflow_dispatch só naquele ambiente)

B) Independente por arquivo de pipeline, mas **todos** disparam no mesmo evento (ex.: push em `main` aplica os três — em geral **não** recomendado)

C) Manual (`workflow_dispatch` / Run pipeline) por ambiente; sem apply automático no push

X) Other (please describe after [Answer]: tag below)

[Answer]: A — independente por ambiente. Branch dev aplica em dev; merge em main aplica em prod (ou workflow_dispatch manual). Nunca "um push aplica os três" (B é perigoso — uma mudança errada vai direto para prod).

---

## Question 6
O `terraform apply` em produção (e hom, se quiser) precisa de aprovação humana no CI?

A) Só **prod** exige aprovação manual; dev aplica automático após plan ok

B) **hom** e **prod** exigem aprovação; **dev** automático

C) Os **três** ambientes exigem aprovação manual antes do apply

D) Nenhum ambiente exige aprovação (plan + apply automáticos)

X) Other (please describe after [Answer]: tag below)

[Answer]: B — hom e prod exigem aprovação; dev automático. Dev é laboratório (iterar rápido); hom é validação (alguém olha antes); prod é produção (aprovação obrigatória). É o padrão que a maioria das empresas usa e o que o GitHub Actions Environments suporta nativamente.

---

## Question 7
Onde ficam os valores por ambiente (`environment`, account id, nomes de buckets, `analytics_principal_arns`)?

A) Arquivos commitados `env/dev.tfvars`, `env/hom.tfvars`, `env/prod.tfvars` (ARNs/account ids no git; buckets como nomes)

B) tfvars de não-segredo no git; **ARNs e account ids** só em secrets/variáveis do CI

C) Tudo em secrets/variáveis do CI; nenhum tfvars de ambiente no git além de `example.tfvars`

X) Other (please describe after [Answer]: tag below)

[Answer]: A — tfvars commitados por ambiente (env/dev.tfvars, env/hom.tfvars, env/prod.tfvars). Nomes de bucket e account IDs não são segredo — são configuração. Segredos de verdade (se houvesse, como chaves de KMS) iriam para secrets do CI, mas neste projeto não há. Commitar os tfvars torna o estado de cada ambiente auditável no git.

---

## Question 8
O backend S3/DynamoDB (ou o bootstrap) já tem **account IDs** das três contas para colocar no código, ou devem ficar só em variáveis do CI?

A) Vou informar os 12 dígitos das três contas no arquivo de respostas (cole após `[Answer]:` se escolher A)

B) Não informar IDs agora; usar placeholders (`AWS_ACCOUNT_ID_DEV` etc.) preenchidos só no CI

X) Other (please describe after [Answer]: tag below)

[Answer]: B — placeholders por enquanto (AWS_ACCOUNT_ID_DEV, etc.), preenchidos no CI. Mesmo que você tenha os IDs, colocar no código agora te amarra; placeholder é mais flexível e coerente com a Q7-A (os tfvars terão os IDs, os workflows terão os secrets).

---

## Question 9
O Projeto 2 (plataforma de dados) também usa essas **mesmas três contas** (dev/hom/prod), ou este incremento é só identidade neste repo?

A) Mesmas três contas — o contrato (buckets/workgroup) continua **por ambiente, na mesma conta** daquele ambiente

B) Só este repo (Projeto 1); Projeto 2 fica fora de escopo agora

X) Other (please describe after [Answer]: tag below)

[Answer]: A — mesmas três contas para o Projeto 2. O contrato continua: P1 cria roles em conta-dev, P2 cria malha em conta-dev. Senão os ARNs não batem. E isso te força a pensar o multi-env do Projeto 2 junto — boa disciplina.

---

## Question 10
Cada pipeline deve fazer o quê, além de `terraform plan` / `apply`?

A) Só `fmt` + `validate` + `plan` + `apply` (destroy só local/manual)

B) `fmt` + `validate` + `plan` + `apply` + job opcional de `destroy` (manual)

C) Incluir também o script `tests/simulate-principal-policy` depois do apply (precisa AWS CLI na runner)

X) Other (please describe after [Answer]: tag below)

[Answer]: C — fmt + validate + plan + apply + simulate (o teste de menor privilégio). O simulate é o que prova que as roles estão certas naquele ambiente. Sem ele, você aplica mas não valida. Precisa de AWS CLI na runner, mas o GitHub Actions já tem isso nativo.

---

## Question 11
As regras da extensão de segurança devem ser aplicadas neste incremento (pipelines + 3 contas)?

A) Sim — aplicar todas as regras SECURITY como restrições bloqueantes (recomendado para aplicações de nível de produção)

B) Não — pular todas as regras SECURITY (adequado para PoCs, protótipos e projetos experimentais)

X) Other (please describe after [Answer]: tag below)

[Answer]: B — pular security baseline neste incremento. O foco agora é a maquinaria de CI/ambientes, não endurecer security. Mas com uma ressalva: o OIDC + aprovação em prod (Q2+Q6) já são práticas de segurança de facto. Baseline completo fica para quando o pipeline estiver estável.

---

## Question 12
O baseline de resiliência deve ser aplicado neste incremento?

**O que esta extensão é.** Ativá-la aplica um conjunto de **melhores práticas direcionais de design** para construir sistemas resilientes, derivadas do **AWS Well-Architected Framework (Reliability Pillar)** e orientações de revisão de resiliência. Ela direciona requisitos, design e código para tolerância a falhas, alta disponibilidade, observabilidade e recuperabilidade.

**O que esta extensão NÃO é.** Ativá-la **não** torna o workload pronto para produção nem certifica RTO/RPO.

A) Sim — aplicar o baseline de resiliência como melhores práticas direcionais e orientação de design (recomendado para workloads críticos de negócio, como ponto de partida informado que você pode validar e endurecer antes do go-live)

B) Não — pular o baseline de resiliência (adequado para PoCs e iteração rápida)

X) Other (please describe after [Answer]: tag below)

[Answer]: B — pular resiliência. O incremento é sobre CI/multi-env, não sobre HA. O backend S3+DynamoDB com versionamento (Q3) já dá resiliência básica ao state.

---

## Question 13
As regras de testes baseados em propriedades (PBT) devem ser aplicadas neste incremento?

A) Sim — aplicar todas as regras PBT como restrições bloqueantes

B) Parcial — aplicar regras PBT apenas para funções puras e round-trips de serialização

C) Não — pular todas as regras PBT (adequado para IaC declarativo / CI sem lógica de negócio)

X) Other (please describe after [Answer]: tag below)

[Answer]: C — sem PBT. Continua IaC declarativa + workflows YAML; não tem lógica de negócio para testar com propriedades.
