# Requirements Clarification Questions

Responda cada pergunta preenchendo a letra após a tag `[Answer]:`.
Se nenhuma opção corresponder, escolha a última opção (Other / Outro) e descreva a preferência.

Fonte: `prd-source.md` (PRD 1.0 — Camada de Identidade / InfraRoles Mini).

---

## Question 1
A role de Analytics será assumida por qual principal? (questão em aberto do PRD #1; federação SSO/IdP corporativo está fora de escopo)

A) Usuário IAM da mesma conta (trust em `arn:aws:iam::<account>:user/<name>`, parametrizado)

B) Role IAM da mesma conta (você assume via console/CLI; trust em ARN de role parametrizado)

C) Ambos: variáveis aceitam lista de ARNs (users e/ou roles)

X) Other (please describe after [Answer]: tag below)

[Answer]: C	Lista de ARNs (users e roles) — flexível e facilita o teste de governança (adicionar uma identidade sem grant)

---

## Question 2
A role de Acesso (automação) entra nesta POC? (questão em aberto do PRD #2; RF5 pede `access_role_arn` nos outputs)

A) Sim — criar a role, a policy, o trust e o output `access_role_arn`

B) Não — omitir a role e o output `access_role_arn` nesta POC

C) Não criar a role agora, mas manter o output `access_role_arn` com valor vazio/null como contrato para o Projeto 2

X) Other (please describe after [Answer]: tag below)

[Answer]:C	Não criar a role de acesso agora, mas manter o output access_role_arn (null) como contrato com o Projeto 2

---

## Question 3
Qual região AWS definitiva para esta POC? (questão em aberto do PRD #3; premissa atual: `sa-east-1` ajustável)

A) `sa-east-1` (São Paulo)

B) `us-east-1` (N. Virginia)

C) Parametrizar `aws_region` com default `sa-east-1`

X) Other (please describe after [Answer]: tag below)

[Answer]: C	Parametrizar aws_region com default sa-east-1 — boa prática + fiel à origem

---

## Question 4
Qual `project_prefix` usar nos nomes das roles/policies? (questão em aberto do PRD #3; RNF5 exige prefixo + environment)

A) `datamesh-poc` (ex.: `datamesh-poc-dev-glue-role`)

B) `infra-roles` (ex.: `infra-roles-dev-glue-role`)

C) `dlc-mesh` (ex.: `dlc-mesh-dev-glue-role`)

X) Other (please describe after [Answer]: tag below)

[Answer]:A	datamesh-poc — prefixo descreve a arquitetura toda, serve aos dois projetos 

---

## Question 5
Como os nomes dos buckets (camadas + resultados Athena) serão fornecidos, para escopar as policies sem `Resource: "*"`?

A) Variáveis Terraform explícitas (ex.: `bronze_bucket`, `silver_bucket`, `gold_bucket`, `athena_results_bucket`)

B) Convenção derivada de `project_prefix` + `environment` + nomes de camada (ex.: `{prefix}-{env}-bronze`)

C) Apenas variáveis; este projeto NÃO cria buckets (Projeto 2 cria; aqui só referencia os nomes nas policies)

X) Other (please describe after [Answer]: tag below)

[Answer]: C	Este projeto não cria buckets (só referencia nomes nas policies); Projeto 2 os cria

---

## Question 6
Quais camadas de dados devem ser referenciadas nas policies da role de Glue (R/W) e da role de Analytics (leitura)?

A) `bronze`, `silver`, `gold`

B) `raw`, `processed`, `curated`

C) `landing`, `raw`, `trusted`, `refined`

X) Other (please describe after [Answer]: tag below)

[Answer]:X	sor, sot, spec — mantém fidelidade ao Itaú e consistência com os DBs do Projeto 2

---

## Question 7
O bucket de resultados do Athena já existirá (Projeto 2) ou este projeto também precisa conhecê-lo só como variável de policy?

A) Apenas variável de nome (`athena_results_bucket`) — bucket criado no Projeto 2

B) Este projeto também cria o bucket de resultados do Athena

C) Usar um prefixo dentro de um bucket de camada (sem bucket dedicado)

X) Other (please describe after [Answer]: tag below)

[Answer]: A	Bucket do Athena é variável aqui, criado no Projeto 2

---

## Question 8
Qual o papel da role de Glue nesta POC?

A) Somente execution role de Glue Job/Crawler (trust `glue.amazonaws.com`; R/W S3 das camadas, catálogo, LF GetDataAccess, logs)

B) Execution role + permissões para criar/atualizar jobs, crawlers e databases Glue

C) Execution role + permissões mínimas de Lake Formation para registrar locations (além de GetDataAccess)

X) Other (please describe after [Answer]: tag below)

[Answer]:A	Glue role = só execution role (menor privilégio)

---

## Question 9
Onde o estado do Terraform deve ser armazenado nesta POC?

A) Backend local (simplicidade da POC; state no disco, fora do git)

B) Backend S3 + locking em DynamoDB (já nesta POC)

C) Backend S3 sem locking

X) Other (please describe after [Answer]: tag below)

[Answer]: A	State local — simplicidade de POC

---

## Question 10
Como estruturar o código Terraform?

A) Módulo raiz plano (arquivos `versions.tf`, `variables.tf`, `main.tf`, `outputs.tf` na raiz)

B) Módulo reutilizável em `modules/iam-roles` consumido por um root module

C) Um arquivo por role (`glue.tf`, `analytics.tf`, `access.tf`) no root module, sem submódulo

X) Other (please describe after [Answer]: tag below)

[Answer]: C	Um arquivo por role — legível e fiel ao estilo dos projetos originais

---

## Question 11
As regras da extensão de segurança devem ser aplicadas neste projeto?

A) Sim — aplicar todas as regras SECURITY como restrições bloqueantes (recomendado para aplicações de nível de produção)

B) Não — pular todas as regras SECURITY (adequado para PoCs, protótipos e projetos experimentais)

X) Other (please describe after [Answer]: tag below)

[Answer]:B	Pular ruleset pesado de segurança, mas manter menor privilégio via RNFs

---

## Question 12
O baseline de resiliência deve ser aplicado neste projeto?

**O que esta extensão é.** Ativá-la aplica um conjunto de **melhores práticas direcionais de design** para construir sistemas resilientes, derivadas do **AWS Well-Architected Framework (Reliability Pillar)** e orientações de revisão de resiliência. Ela direciona requisitos, design e código para tolerância a falhas, alta disponibilidade, observabilidade e recuperabilidade — cobrindo 15 áreas de prática entre objetivos de negócio, gerenciamento de mudanças, observabilidade, alta disponibilidade, recuperação de desastres e melhoria contínua.

**O que esta extensão NÃO é.** Ativá-la **não** torna seu workload pronto para produção, nem certifica ou garante qualquer alvo de disponibilidade, RTO ou RPO. É um **ponto de partida** que estrutura boas decisões de resiliência cedo — não é um substituto para um **AWS Well-Architected Review** formal do sistema construído.

Trate a saída como um **primeiro rascunho bem fundamentado da sua postura de resiliência** para construir e validar — não um resultado final certificado para produção.

A) Sim — aplicar o baseline de resiliência como melhores práticas direcionais e orientação de design (recomendado para workloads críticos de negócio, como ponto de partida informado que você pode validar e endurecer antes do go-live)

B) Não — pular o baseline de resiliência (adequado para PoCs, protótipos e projetos experimentais onde iteração rápida importa mais do que confiabilidade)

X) Other (please describe after [Answer]: tag below)

[Answer]: B	Sem baseline de resiliência — irrelevante numa POC

---

## Question 13
As regras de testes baseados em propriedades (PBT) devem ser aplicadas neste projeto?

A) Sim — aplicar todas as regras PBT como restrições bloqueantes (recomendado para projetos com lógica de negócio, transformações de dados, serialização ou componentes com estado)

B) Parcial — aplicar regras PBT apenas para funções puras e round-trips de serialização (adequado para projetos com complexidade algorítmica limitada)

C) Não — pular todas as regras PBT (adequado para aplicações CRUD simples, projetos apenas de UI ou camadas finas de integração sem lógica de negócio significativa)

X) Other (please describe after [Answer]: tag below)

[Answer]:C	Sem PBT — é IaC declarativo, não tem lógica de negócio
