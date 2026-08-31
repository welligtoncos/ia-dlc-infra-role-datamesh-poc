# NFR Design Plan — u3-identity-ci

**Estágio**: CONSTRUCTION — Design NFR (planejamento)
**Unidade**: `u3-identity-ci`
**Entrada**: `nfr-requirements.md` + `tech-stack-decisions.md` (concurrency sem cancel; timeout 20; OIDC; plan artifact + apply Environment; reusable workflow; Terraform 1.9.8 no CI).

Preencha cada `[Answer]:`. Artefatos em `nfr-design/` só após as respostas.

Sem filas SQS, caches de aplicação, circuit breakers de runtime — a unidade é pipeline + arquivos de config.

---

## Question 1
Padrão de resiliência: falha transitória (OIDC/IAM ainda não visível, lock, download do artifact)?

A) Retry **só** no `configure-aws-credentials` / primeiro `terraform init` (ex.: 3 tentativas com sleep) se `AccessDenied`/`Not authorized`. Lock DynamoDB: deixar o Terraform nativo (segundo run espera ou falha). Artifact `tfplan`: se o apply não achar o artifact, falhar o job (re-run do workflow). Sem force-unlock no CI

B) Sem retry no YAML; README: re-executar o workflow se o primeiro assume falhar. Igual no lock/artifact

C) Job de `force-unlock` automático no CI se o apply falhar (perigoso)

X) Other (please describe after [Answer]: tag below)

[Answer]:A — retry no configure-aws-credentials / primeiro init (3 tentativas com sleep). O OIDC + IAM eventual consistency é o mesmo gotcha que pegamos na POC v1 — a role recém-criada pelo bootstrap pode não estar imediatamente visível. Retry no ponto certo (o assume) resolve sem complicar o resto. Lock: nativo do Terraform (sem force-unlock no CI — C é perigoso). Artifact não encontrado: falhar o job (re-run manual). Pragmático e seguro.

---

## Question 2
Padrão de escala (já três callers + concurrency por env)?

A) Nenhum componente extra. Limite = três ambientes. Sem `strategy.matrix` num único workflow (quebraria isolamento RF-ME4/ME7)

B) Um workflow com matrix `dev/hom/prod` e `if:` por branch (contraria “três pipelines independentes”)

X) Other (please describe after [Answer]: tag below)

[Answer]:A — nenhum componente extra, sem matrix. Três callers finos já resolvem. Matrix num workflow único (B) quebraria o isolamento RF-ME4/RF-ME7 — os três ambientes rodariam no mesmo workflow, e um concurrency por env ficaria mais difícil de garantir. Separar é mais seguro e é o que os requisitos pedem.

---

## Question 3
Padrão de desempenho (timeout 20 min já fechado)?

A) Sem cache de providers: cada job faz `terraform init` limpo (reprodutível; IAM-only é rápido)

B) `actions/cache` na pasta de plugins Terraform para encurtar init

X) Other (please describe after [Answer]: tag below)

[Answer]:A — sem cache de providers. IAM-only leva segundos no init; cache adicionaria complexidade (invalidação, path, permissão) para ganhar poucos segundos num job de 2–3 minutos. Reprodutibilidade vale mais que velocidade aqui — cada job parte do zero, sem risco de plugin stale.

---

## Question 4
Padrão de segurança do **artifact `tfplan`** e do reusable workflow?

A) Artifact privado do run, **retention-days: 1**; `actions: read` só o necessário no job apply; reusable workflow com `secrets: inherit` **proibido** (não há secrets de AWS). Variáveis: `AWS_ROLE_ARN` (e região) no GitHub Environment. `permissions` no reusable + callers alinhados ao NFR (`contents: read`, `id-token: write`)

B) Retention 90 dias (plan antigo fica disponível tempo demais)

C) Publicar o `tfplan` como release/asset do repo (expõe o plano)

X) Other (please describe after [Answer]: tag below)

[Answer]:A — artifact com retention-days: 1, sem secrets: inherit, variáveis no GitHub Environment. O racional de cada ponto: retention 1 dia porque o plan só importa entre o plan e o apply (minutos/horas), não depois — 90 dias (B) deixaria plans antigos com informação de infra acessíveis sem motivo. Sem secrets: inherit porque não há secrets AWS (só OIDC + variáveis de environment); herdar secrets que não existem é permissão aberta para nada. E permissions alinhadas no reusable e nos callers — porque o GitHub Actions herda a permissão mais restritiva entre os dois, então ambos precisam declarar.

---

## Question 5
Quais componentes lógicos NFR (além dos três YAML “de fachada”)?

A) `ReusableDeployWorkflow` (fmt-check, init `-backend-config`, validate, plan `-out`, artifact, apply `tfplan`, simulate.sh); `DeployCallerDev|Hom|Prod` (`on:` + inputs); `EnvTfvars` + `BackendHcl`; `IdentityBackendPartial` (bloco `backend "s3"` vazio no root U1); `EnvironmentValidation` (`environment` ∈ {dev,hom,prod}); `ConcurrencyGroup`; `GitIgnoreEnvTfvarsAllow`; `IdentityCiReadme` (hom, var-file, .ps1 vs .sh, Environments)

B) A + GitHub Composite Action extra (camada a mais além do reusable)

C) Só os três YAML; backend/tfvars/gitignore ficam implícitos no Code Generation

X) Other (please describe after [Answer]: tag below)

[Answer]:A — a lista completa de componentes lógicos. Composite Action (B) seria mais uma camada entre o caller e o reusable sem ganho — o reusable já centraliza a lógica. C (só os YAML) esconderia decisões que precisam ser rastreáveis (backend parcial, concurrency group, gitignore dos env tfvars). A lista em A reflete exatamente o que vai ser gerado na Code Generation: cada componente vira um arquivo ou um bloco identificável.

---

## Checklist de execução (após respostas)

- [x] Gerar `aidlc-docs/construction/u3-identity-ci/nfr-design/nfr-design-patterns.md`
- [x] Gerar `aidlc-docs/construction/u3-identity-ci/nfr-design/logical-components.md`
- [x] Atualizar checkboxes e `aidlc-state.md`

---

## Regras

- Extensões Security / Resiliency / PBT: N/A
- Sem WAF, self-hosted, access keys, destroy no CI
- Não reescrever glue.tf / analytics.tf (só validation + backend no root)
