# Application Design Plan — Incremento multi-env

**Estágio**: INCEPTION — Design da Aplicação (planejamento)
**Fontes**: `requirements.md`, `execution-plan.md`, RE, POC v1 (`application-design-plan-poc-v1.md`)
**Adaptação**: IaC Terraform + GitHub Actions (sem API HTTP). Componentes = blocos lógicos; “métodos” = interfaces (entradas/saídas / operações).

Preencha cada `[Answer]:`. A geração dos artefatos em `aidlc-docs/inception/application-design/` só começa após as respostas (e esclarecimentos, se houver).

---

## Contexto já fechado (não perguntar de novo)

- Três contas fixas; uma pipeline GitHub Actions por ambiente; OIDC; sem access keys
- `bootstrap/` aplicado **uma vez por conta** (admin local): S3 + DynamoDB + OIDC provider + deploy role
- Root de identidade (Glue/Analytics) **não** muda de propósito; ganha backend remoto + `environment` in {dev,hom,prod}
- CI: `-var-file=env/{env}.tfvars`; local: `terraform.tfvars` sem `-var-file`
- Simulate: `.sh` no CI, `.ps1` no Windows; branch `hom` obrigatória no remote
- GlueIdentity / AnalyticsIdentity / OutputContract da POC v1 **permanecem** dentro do root de identidade
- Sem Terragrunt, sem Terraform Cloud, sem criar contas Organizations

---

## Perguntas de design

## Question 1
Quais limites de componentes lógicos novos devem aparecer em `components.md` (além de GlueIdentity, AnalyticsIdentity, OutputContract da POC v1)?

A) Três novos: `BootstrapStack` (S3, DynamoDB, OIDC provider, deploy role), `EnvConfig` (tfvars + backend-config), `CiPipelines` (três workflows)

B) Dois novos: `BootstrapStack` e `CiPipelines` — tfvars/backend-config são interface do root de identidade, não componente

C) Quatro novos: separar `DeployRole` (OIDC) de `StateBackend` (S3+DDB) além de `EnvConfig` e `CiPipelines`

X) Other (please describe after [Answer]: tag below)

[Answer]: A — três novos (BootstrapStack, EnvConfig, CiPipelines). Cada um tem responsabilidade, ciclo de vida e operador diferentes: bootstrap é admin local/uma vez, EnvConfig é configuração versionada, CiPipelines é automação contínua. Juntar EnvConfig no root (B) esconde que os tfvars + backend-config são a superfície de variação por ambiente — que é justamente o ponto central do incremento. Separar OIDC de StateBackend (C) fragmenta demais o que nasce e morre junto num único apply de bootstrap.

---

## Question 2
Como representar “métodos” / interfaces em `component-methods.md`?

A) `BootstrapStack.apply_once` / `destroy_local`; Identity root `plan`/`apply`/`output` (inalterado); `CiPipelines.run(env)` com sequência fmt→validate→plan→apply→simulate.sh

B) Só operações Terraform dos dois roots; workflows são detalhe de Construction, sem “métodos” de componente CI

C) Híbrido: Terraform nos dois roots + `CiPipelines.run(env)`; sem `destroy` na interface de CI (já é não-objetivo)

X) Other (please describe after [Answer]: tag below)

[Answer]: C — híbrido. Terraform nos dois roots (BootstrapStack.apply_once/destroy_local, Identity plan/apply/output) + CiPipelines.run(env) com a sequência completa. Sem destroy na interface de CI (já é não-objetivo). B esconderia o workflow como "detalhe" quando ele é um dos três entregáveis do incremento; A incluiria destroy que os requisitos excluem.

---

## Question 3
O que é a “camada de serviço” em `services.md`?

A) Dois serviços: `BootstrapService` (apply local uma vez por conta) e `DeployService` (GitHub Actions orquestra o root de identidade). Nenhum apply único cobre os dois.

B) Um serviço `MultiEnvIdentity`: o runbook do engenheiro é a orquestração (bootstrap depois pipeline); CI não é serviço, só ferramenta

C) Três serviços (um por ambiente) mesmo com o mesmo código — orquestração só por isolation de conta

X) Other (please describe after [Answer]: tag below)

[Answer]: A — dois serviços: BootstrapService (local, uma vez) e DeployService (CI, contínuo). Eles têm ciclos de vida opostos — o bootstrap roda uma vez e é esquecido; o deploy roda a cada push. Fundir num serviço (B) esconde essa diferença fundamental. Três por ambiente (C) é artificial — é o mesmo código, mesma pipeline, só os valores mudam.

---

## Question 4
Como o root de identidade depende do bootstrap (backend já existe na conta)?

A) Dependência **operacional** só: o engenheiro aplica bootstrap antes; o identity root **não** usa `terraform_remote_state` nem data source dos outputs do bootstrap. CI recebe bucket/tabela/role via vars GitHub / `-backend-config`.

B) Identity root lê outputs do bootstrap via `terraform_remote_state` (state local do bootstrap ou S3 após migrar)

C) Identity root é um módulo que chama `bootstrap` (um apply só) — rejeita o ovo-e-galinha da role OIDC

X) Other (please describe after [Answer]: tag below)

[Answer]: A — dependência operacional só. O identity root não usa terraform_remote_state nem data source do bootstrap. O CI recebe bucket/tabela/role via vars GitHub e -backend-config. Isso é mais limpo e mais seguro: B acopla os states (o root precisa saber onde está o state do bootstrap — circular se o bootstrap é local); C rejeita o ovo-e-galinha sem resolvê-lo.

---

## Question 5
Onde vive a configuração do backend S3 do identity root?

A) Backend **parcial** no `versions.tf` (sem bucket/key); CI e docs passam `-backend-config` (e opcionalmente `env/{env}.backend.hcl` não commitado ou commitado)

B) Arquivos commitados `env/dev.backend.hcl`, `env/hom.backend.hcl`, `env/prod.backend.hcl` (bucket/key/table placeholders) + `terraform init -backend-config=...`

C) `backend "s3"` completo no `.tf` com placeholders de bucket; um único bloco (não serve para 3 contas sem edição)

X) Other (please describe after [Answer]: tag below)

[Answer]: B — arquivos commitados env/{env}.backend.hcl (bucket, key, table, region — com placeholders). O terraform init -backend-config=env/dev.backend.hcl é explícito e auditável. A (backend parcial sem arquivo) funciona mas esconde a configuração nos workflows YAML, menos visível. C (bloco completo no .tf) não serve para 3 contas sem editar o código. B dá rastreabilidade no git sem hardcodar valores no .tf.

---

## Question 6
`CiPipelines` depende de quais componentes?

A) Depende de `BootstrapStack` (role OIDC já existe) e do **código** do identity root + `EnvConfig`; **não** declara resources AWS. Glue/Analytics só entram depois do `apply` do identity.

B) Depende só do identity root; bootstrap é premissa documental, não dependência de design

C) CiPipelines também “possui” o simulate e o fmt — IdentityVerification da POC v1 continua fora (Build/Test), mas o workflow **chama** o script

X) Other (please describe after [Answer]: tag below)

[Answer]: A — depende de BootstrapStack (a role OIDC precisa existir) e do código do identity root + EnvConfig (os tfvars que o workflow referencia). Não declara resources AWS — é YAML, não Terraform. B subestima a dependência do bootstrap (sem a role OIDC, o workflow falha no primeiro passo). C mistura "o workflow chama o script" (que é verdade) com ownership — o simulate continua sendo verificação (Build/Test), não componente da pipeline; o workflow apenas invoca.  

---

## Question 7
Padrão de composição (dois roots + CI)?

A) Composição **plana e desacoplada**: dois states Terraform independentes; GitHub YAML não é Terraform; IdentityPlatform da POC v1 continua o rótulo do apply de identidade

B) Fachada única `MultiEnvPlatform` na documentação, mesmo sem um apply que una bootstrap + identity

C) Terragrunt / wrapper que chama os dois roots em ordem (não está nos requisitos)

X) Other (please describe after [Answer]: tag below)

[Answer]: A — composição plana e desacoplada. Dois states independentes, GitHub YAML não é Terraform, IdentityPlatform da POC v1 continua como rótulo do apply de identidade. B inventaria uma fachada para algo que não tem um apply unificador. C (Terragrunt) está explicitamente fora dos requisitos.

---

## Checklist de execução (após respostas + aprovação do plano, se pedida)

- [x] Carregar requirements, execution-plan, RE e respostas deste plano
- [x] Gerar `aidlc-docs/inception/application-design/components.md` (POC v1 + componentes novos)
- [x] Gerar `aidlc-docs/inception/application-design/component-methods.md`
- [x] Gerar `aidlc-docs/inception/application-design/services.md`
- [x] Gerar `aidlc-docs/inception/application-design/component-dependency.md` (matriz + mermaid + alternativa texto)
- [x] Gerar `aidlc-docs/inception/application-design/application-design.md` (consolidado; emenda à POC v1, não apagar Glue/Analytics)
- [x] Validar: RF-ME1–RF-ME7; ovo-e-galinha; var-file CI vs local; .sh vs .ps1; branch hom
- [x] Atualizar checkboxes e `aidlc-state.md`

---

## Regras da geração

- Idioma: português
- Sem lista completa de `aws_*` / YAML steps (isso é Construction / Infrastructure Design)
- Extensões Security / Resiliency / PBT: N/A
- Preservar GlueIdentity, AnalyticsIdentity, OutputContract; este incremento **acrescenta** limites, não substitui a identidade
