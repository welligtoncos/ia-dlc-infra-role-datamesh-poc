# Unit of Work Plan — Incremento multi-env

**Estágio**: INCEPTION — Geração de Unidades (Parte 1: Planejamento)
**Fontes**: `application-design.md`, `execution-plan.md` (rascunho U2/U3), `requirements.md`
**Histórias**: puladas neste incremento — o mapa usará RF-ME1–RF-ME7 + U1 já mapeada (US-1..US-6)

Preencha cada `[Answer]:`. A Parte 2 só começa após as respostas **e** a aprovação explícita deste plano.

## Decisões resolvidas (respostas)

| Q | Decisão |
|---|---------|
| 1 | Duas unidades: `u2-bootstrap` depois `u3-identity-ci` |
| 2 | Construction em série: U2 completa (NFR + infra + código) antes da Construction da U3 |
| 3 | Um dono (P1) nas duas |
| 4 | Unidades separadas, DoD e apply próprios |
| 5 | Dois bounded contexts: preparação da conta vs publicação da identidade |
| 6 | `bootstrap/` + `env/` + `.github/workflows/`; identity **permanece na raiz** |

**Unidades a gerar:** `u2-bootstrap` = BootstrapService. `u3-identity-ci` = DeployService (EnvConfig + backend no root U1 + CiPipelines). U1 inalterada.

---

## Contexto já fechado

- U1 `u1-identity-iam` **completa** (Glue/Analytics/outputs na raiz). Não reabrir o loop de Construction da U1 para reescrever policies.
- Componentes novos: BootstrapStack, EnvConfig, CiPipelines
- Serviços: BootstrapService (local, uma vez) e DeployService (CI)
- Dois states Terraform independentes; sem `terraform_remote_state`
- `env/{env}.backend.hcl` e `env/{env}.tfvars` commitados
- Functional Design SKIP na Construction deste incremento

**Terminologia:** Unidade = loop de Construction. Serviço = BootstrapService ou DeployService. U1 continua um serviço IdentityPlatform já implantável.

---

## Question 1
Como agrupar o incremento em unidades de trabalho? (afinidade Bootstrap vs Deploy)

A) Duas unidades sequenciais: `u2-bootstrap` (BootstrapStack / BootstrapService) e `u3-identity-ci` (EnvConfig + backend no root U1 + CiPipelines / DeployService)

B) Uma unidade `u2-multi-env`: bootstrap + env + workflows + backend no mesmo loop de Construction

C) Três unidades: `u2-bootstrap`, `u3-env-config`, `u4-ci-pipelines`

X) Other (please describe after [Answer]: tag below)

[Answer]: A — duas unidades sequenciais: u2-bootstrap e u3-identity-ci. Elas têm ciclos de vida opostos (uma vez vs contínuo), applies diferentes (local vs CI), e states diferentes (local vs remoto). Juntar (B) misturaria one-shot com contínuo num único DoD; fragmentar em três (C) separaria EnvConfig das pipelines que a consomem, criando dependência sem ganho.

---

## Question 2
Se houver mais de uma unidade, como ordenar Construction e o apply?

A) Construction **em série**: terminar U2 (design NFR/infra + código bootstrap) **antes** de começar Construction da U3. Apply: bootstrap por conta **antes** do primeiro `run(env)`.

B) Projetar U2 e U3 juntas (NFR/infra únicos) e só fatiar o Code Generation (primeiro `bootstrap/`, depois workflows)

C) Loops de Construction em paralelo (dois agents) — não recomendado: U3 assume OIDC/backend já definidos

X) Other (please describe after [Answer]: tag below)

[Answer]: A — Construction em série. Terminar U2 (design + código do bootstrap) antes de começar U3. O motivo é concreto: o NFR Design e o Infra Design da U3 assumem que a role OIDC e o backend existem (definidos na U2). Projetar U3 sem saber os nomes/ARNs/formato do bootstrap seria chutar. E o apply é naturalmente serial: bootstrap → pipeline.

---

## Question 3
Ownership das unidades?

A) Um dono (engenheiro P1): todas as unidades deste incremento

B) Dono A = bootstrap/contas; dono B = GitHub Actions / Environments

X) Other (please describe after [Answer]: tag below)

[Answer]: A — um dono (P1). POC pessoal, uma pessoa faz tudo. Separar donos (B) só faria sentido com times distintos (infra de conta vs DevOps), que não é o caso.

---

## Question 4
Implantação: bootstrap e identity precisam de ciclos de vida separados (já é requisito). Isso implica unidades separadas ou só pastas na mesma unidade?

A) Unidades separadas — cada uma tem apply próprio (bootstrap local vs identity/CI) e Definition of Done próprio

B) Uma unidade, duas pastas — um único DoD no final (mais simples, mas mistura one-shot e contínuo)

X) Other (please describe after [Answer]: tag below)

[Answer]: A — unidades separadas. Cada uma tem apply próprio, Definition of Done próprio, e frequência de execução oposta (bootstrap = uma vez; identity/CI = toda vez). Juntar numa unidade com "duas pastas" (B) daria um único DoD que só fecha quando os dois estiverem prontos — e o bootstrap já estaria pronto muito antes dos workflows. Unidades separadas permitem fechar e "esquecer" o bootstrap antes de mergulhar no CI.

---

## Question 5
Bounded context de negócio deste incremento?

A) Dois contextos: **preparação da conta** (backend + OIDC) vs **publicação da identidade** (roles + pipeline)

B) Um contexto: plataforma multi-env da camada de identidade (bootstrap é só pré-requisito técnico no mesmo contexto da U1)

X) Other (please describe after [Answer]: tag below)

[Answer]: A — dois contextos: preparação da conta (backend + OIDC) e publicação da identidade (roles + pipeline). Repara que eles falam linguagens diferentes: U2 fala de "bucket de state, tabela de lock, provedor OIDC, trust do GitHub"; U3 fala de "roles Glue/Analytics, -var-file, approve environment". São vocabulários distintos, o que em DDD é justamente o sinal de bounded contexts separados. B forçaria tudo no mesmo contexto quando o bootstrap existe para ser feito e esquecido — não é parte do dia a dia da identidade.

---

## Question 6
Onde fica o código novo na raiz do workspace? (brownfield; U1 já ocupa a raiz com `.tf`)

A) `bootstrap/` = segundo root; `env/` = tfvars + backend.hcl; `.github/workflows/` = três YAML; identity **permanece na raiz** (não mover `glue.tf`)

B) Mover o identity root para `identity/` e deixar `bootstrap/` ao lado (refatoração da U1)

C) Tudo de CI/bootstrap sob `terraform/` (`terraform/bootstrap`, `terraform/env`) e workflows em `.github/`

X) Other (please describe after [Answer]: tag below)

[Answer]: A — bootstrap/ como segundo root, env/ para tfvars + backend.hcl, .github/workflows/ para os YAMLs, identity permanece na raiz. Mover glue.tf para identity/ (B) seria refatoração da U1 (que está fechada e provisionada — mexer no path dos arquivos pode exigir state mv). E terraform/ (C) adiciona profundidade sem ganho. A preserva o brownfield sem tocar no que já funciona.

---

## Checklist de execução (Parte 2 — após aprovação)

- [x] Carregar design, requirements, este plano aprovado e artefatos U1
- [x] Gerar `aidlc-docs/inception/application-design/unit-of-work.md` (U1 preservada + unidades novas)
- [x] Gerar `aidlc-docs/inception/application-design/unit-of-work-dependency.md`
- [x] Gerar `aidlc-docs/inception/application-design/unit-of-work-story-map.md` (RF-ME + US-1..US-6 na U1)
- [x] Documentar organização de código das unidades novas
- [x] Validar: U2 antes de U3 no apply real; sem remote_state; sem destroy no CI
- [x] Atualizar checkboxes e `aidlc-state.md`

---

## Regras da geração

- Idioma: português
- Não apagar a definição de `u1-identity-iam`; acrescentar unidades
- Extensões Security / Resiliency / PBT: N/A
- Story-map: histórias de usuário deste incremento = N/A; usar RFs
