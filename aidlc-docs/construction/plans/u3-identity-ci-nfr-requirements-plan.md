# NFR Requirements Plan — u3-identity-ci

**Estágio**: CONSTRUCTION — Requisitos NFR (planejamento)
**Unidade**: `u3-identity-ci`
**Design funcional**: SKIP (execution-plan). Base: `requirements.md` RF-ME1/2/4/5/6/7, `components.md` EnvConfig + CiPipelines, `unit-of-work.md`.
**Já fechado**: GitHub Actions; três workflows (`deploy-dev` / `deploy-hom` / `deploy-prod`); OIDC (`aws-actions/configure-aws-credentials`); runners `ubuntu-latest`; sequência fmt-check → init → validate → plan `-var-file` → apply → `simulate-principal-policy.sh`; hom/prod com GitHub Environment (aprovação); sem destroy no CI; Terraform `>= 1.7.5` + AWS `~> 5.0`; glue/analytics **não** reescritos (só validation `environment` + backend); U2 já criou bucket/lock/role; extensões Security/Resiliency/PBT desabilitadas.

Preencha cada `[Answer]:`. Artefatos em `aidlc-docs/construction/u3-identity-ci/nfr-requirements/` só após as respostas.

Usabilidade de UI: **N/A**.

---

## Question 1
Escalabilidade / concorrência: dois pushes no mesmo ambiente ao mesmo tempo?

A) `concurrency` por workflow (um apply por env). Fila — **não** cancelar o run em andamento (evita lock DynamoDB órfão e apply pela metade)

B) `concurrency` com `cancel-in-progress: true` (dev só, ou todos) — mais rápido, risco de lock se o cancel cair no meio do apply

C) Sem `concurrency` — o lock DynamoDB resolve sozinho (segundo apply espera ou falha)

X) Other (please describe after [Answer]: tag below)

[Answer]:A — concurrency por workflow, fila sem cancelar. O lock do DynamoDB tecnicamente resolve (C), mas cancelar um run no meio do apply (B) pode deixar o state locked sem ninguém para desbloquear — aí é force-unlock manual, que é dor. Fila é mais seguro: o segundo push espera o primeiro terminar. E não cancelar o run em andamento protege contra apply pela metade.

---

## Question 2
Desempenho: há alvo de duração do job CI (fmt → apply → simulate)?

A) Nenhum SLO — timeout padrão do GitHub Actions (360 min) é aceitável; IAM-only costuma ser poucos minutos

B) `timeout-minutes` no job (ex.: 20) para falhar cedo se o runner travar

X) Other (please describe after [Answer]: tag below)

[Answer]:B — timeout-minutes: 20. IAM-only leva 2–3 minutos na prática; se passar de 20, algo travou (runner preso, API throttled, lock não liberado). Timeout curto te avisa cedo em vez de gastar 360 minutos de runner para descobrir que congelou. Custo zero, ganho real.

---

## Question 3
Disponibilidade dos runners?

A) Só GitHub-hosted `ubuntu-latest`. Sem self-hosted, sem HA da pipeline. Indisponibilidade do GitHub = não aplica (aceitável nesta POC)

B) Self-hosted na conta (fora do espírito “OIDC + ubuntu-latest” já fechado)

X) Other (please describe after [Answer]: tag below)

[Answer]:A — só GitHub-hosted ubuntu-latest. Self-hosted é infraestrutura a mais para manter, contra o espírito serverless do CI. Indisponibilidade do GitHub = não aplica, aceitável na POC.

---

## Question 4
Segurança do workflow (além de OIDC + Environment já fechados)?

A) `permissions` mínimas: `contents: read`, `id-token: write`; checkout com `persist-credentials: false`; **sem** `pull_request` que faça apply. ARN da role = variável do GitHub Environment (não access key)

B) A, mas **sem** `persist-credentials: false` (default do checkout)

C) A + exigir GitHub Environment também em **dev** (aprovação humana em todo apply)

X) Other (please describe after [Answer]: tag below)

[Answer]:A — permissions mínimas (contents: read, id-token: write), persist-credentials: false, sem pull_request que faça apply. Cada detalhe importa: persist-credentials: false evita que o token do checkout fique no disco do runner após o job; id-token: write é o mínimo para o OIDC funcionar; e nunca fazer apply num PR event (senão um PR malicioso aplica em prod). C (aprovação em dev) contraria o Q6-B dos requisitos (dev automático).

---

## Question 5
Stack no CI: como instalar o Terraform?

A) `hashicorp/setup-terraform` com `terraform_version` **1.7.5** (mínimo do `required_version`) e `terraform_wrapper: false` (CLI nua para scripts)

B) `hashicorp/setup-terraform` com versão **1.9.8** (ou outra 1.9.x pinada) — acima do mínimo, alinhada a versões atuais; `terraform_wrapper: false`

C) Instalar Terraform via `apt`/binário sem a action HashiCorp

X) Other (please describe after [Answer]: tag below)

[Answer]:B — setup-terraform com versão 1.9.x pinada e terraform_wrapper: false. Aqui a escolha é pragmática: 1.7.5 é o mínimo, não o recomendado. Pinar numa 1.9.x te dá bugfixes e melhorias do provider sem quebrar compatibilidade (o required_version >= 1.7.5 aceita). E terraform_wrapper: false é obrigatório para que os scripts de simulate consigam ler a saída do CLI sem o wrapper interferir.

---

## Question 6
Confiabilidade: plan salvo vs apply “solto”, e simulate?

A) `terraform plan -out=tfplan` e `terraform apply tfplan` no **mesmo** job. Hom/prod: o job inteiro usa `environment:` (aprovação **antes** de fmt/plan — o aprovador espera o job começar). Simulate **falha o job** se o script sair ≠ 0

B) Dois jobs: `plan` (sem aprovação) grava artifact `tfplan`; `apply` (Environment hom/prod) baixa o artifact e aplica **só** aquele plano. Simulate falha o job. Dev: um job sem aprovação, ainda com `-out`

C) `terraform apply -auto-approve` sem arquivo de plan (RF-ME5 ao pé da letra, menos garantia de que o apply = o plan revisado)

X) Other (please describe after [Answer]: tag below)

[Answer]:B — dois jobs: plan sem aprovação (grava artifact tfplan) + apply com Environment (baixa o artifact e aplica aquele plano exato). Simulate falha o job. Esta é a escolha mais importante deste gate, e merece o racional:

O aprovador vê o plan antes de aprovar — em A, a aprovação acontece antes do plan rodar (o job inteiro está atrás do gate do Environment). Em B, o plan roda sem aprovação, o aprovador lê o plan no log, e só então libera o apply. É a diferença entre "aprovo para ver o que vai fazer" e "vi o que vai fazer e aprovo".
O apply executa exatamente o plan revisado — o arquivo tfplan é o artifact. Sem ele (C), o apply recalcula o plan e pode divergir (alguém fez outra mudança entre o plan e o apply).
Em dev: um job só, sem aprovação, mas ainda com -out + apply tfplan para consistência.

---

## Question 7
Manutenibilidade dos três YAML?

A) Três arquivos **completos e duplicados** (`deploy-dev.yml` / `deploy-hom.yml` / `deploy-prod.yml`) — explícito no git, nomes do RF-ME4, drift aceito nesta POC

B) Um workflow reutilizável (`.github/workflows/deploy-identity.yml`) + três callers finos (só `on:` + `environment` + `var-file`)

X) Other (please describe after [Answer]: tag below)

[Answer]:B — workflow reutilizável + três callers finos. A é tentadora por ser explícita, mas três YAMLs completos e duplicados são drift garantido com o tempo — você muda um step num, esquece nos outros dois, e hom/prod ficam dessincronizados. O workflow reutilizável centraliza a lógica num lugar; os callers só declaram on:, environment e qual var-file/backend.hcl usar. Menos drift, mesma clareza.

---

## Checklist de execução (após respostas)

- [x] Gerar `aidlc-docs/construction/u3-identity-ci/nfr-requirements/nfr-requirements.md`
- [x] Gerar `aidlc-docs/construction/u3-identity-ci/nfr-requirements/tech-stack-decisions.md`
- [x] Atualizar checkboxes e `aidlc-state.md`

---

## Regras

- Idioma: português
- Extensões: N/A
- Não reabrir Glue/Analytics policies; não gerar YAML até Code Generation da U3
