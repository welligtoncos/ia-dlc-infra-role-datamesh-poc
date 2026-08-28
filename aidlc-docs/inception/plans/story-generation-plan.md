# Story Generation Plan — InfraRoles Mini

**Estágio**: INCEPTION — Histórias de Usuário (Parte 1: Planejamento)
**Fonte**: `aidlc-docs/inception/requirements/requirements.md`
**Avaliação**: `aidlc-docs/inception/plans/user-stories-assessment.md` (Execute = Yes)

Preencha cada tag `[Answer]:` abaixo. Avise quando terminar. A geração (Parte 2) só começa após as respostas **e** a aprovação explícita deste plano.

## Decisões resolvidas (respostas)

| Q | Decisão |
|---|---------|
| 1 | Híbrido: uma história por capability; cada história declara persona + valor |
| 2 | 5–7 histórias (granularidade por capability) |
| 3 | Glue Job **não** é persona; entra só nos critérios de aceite da role Glue |
| 4 | Projeto 2 **não** é persona; contrato fica na história de outputs |
| 5 | Gherkin para assume-role / consumo; checklist para provisionamento Terraform |
| 6 | Negação em cada role **e** história transversal RF7 (`simulate-principal-policy`) |
| 7 | `access_role_arn = null` é critério da história de outputs, não história própria |

**Personas a gerar:** Engenheiro de dados, Analista/BI. Glue Job e Projeto 2 não são personas.

**Conjunto previsto (~6 histórias):** Glue execution role; Analytics leitura governada; contrato de outputs; parametrização; validação RF7; destroy limpo.

**Resolução Q1-D vs Q3-B:** Q3 prevalece. Histórias usam Engenheiro ou Analista como persona; o Glue Job não aparece no formato “Como Glue Job”.

---

## 1. Metodologia

Converter RF1–RF7 e as personas do documento de requisitos em histórias INVEST, sem detalhar implementação Terraform (sem lista de resources, arquivos `.tf` ou sprints).

Artefatos obrigatórios da Parte 2:
- `aidlc-docs/inception/user-stories/personas.md`
- `aidlc-docs/inception/user-stories/stories.md`

---

## 2. Opções de decomposição (trade-offs)

| Abordagem | Benefício | Risco neste projeto |
|-----------|-----------|---------------------|
| Jornada do usuário | Segue apply → validar → entregar ARNs | Pode misturar Glue e Analytics na mesma história |
| Funcionalidade | Uma história por capability (Glue, Analytics, outputs, simulação) | Menos ênfase no ator |
| Persona | Agrupa por Engenheiro / Glue Job / Analista | Glue Job é sistema; histórias podem ficar artificiais |
| Domínio | IAM vs contrato vs validação | Poucos domínios; pode ficar grosso demais |
| Epic | Epics por role com sub-histórias | Overhead alto para uma POC de 2 roles |
| Híbrido | Epics leves por capability + ator explícito em cada história | Precisa regra clara (ver pergunta 1) |

---

## 3. Perguntas de planejamento

## Question 1
Qual abordagem de decomposição deve guiar as histórias?

A) Por funcionalidade: Glue role, Analytics role, contrato de outputs, validação de menor privilégio, destroy limpo

B) Por persona: um conjunto de histórias para o Engenheiro, outro para o Glue Job, outro para o Analista/BI

C) Por jornada: provisionar identidade → assumir/usar a role → entregar ARNs ao Projeto 2

D) Híbrido: organizar por funcionalidade (A), mas cada história declara persona + valor; Glue Job e Analista aparecem como atores nas histórias de uso da role, não só o engenheiro

X) Other (please describe after [Answer]: tag below)

[Answer]:D (híbrido)	Uma história por capability, mas cada uma com persona + valor explícitos

---

## Question 2
Qual granularidade das histórias?

A) Uma história por capability de negócio (cerca de 5–7 histórias: Glue, Analytics, outputs/contrato, parametrização, simulação de menor privilégio, destroy)

B) Mais fina (separar trust, policy, naming/tags, cada output)

C) Mais grossa (2–3 histórias cobrindo todo o módulo IAM)

X) Other (please describe after [Answer]: tag below)

[Answer]:	A	~5–7 histórias — granularidade certa para 2 roles

---

## Question 3
O Glue Job deve ser persona/ator de história (sistema) ou só aparecer nos critérios de aceite?

A) Persona de sistema: histórias do tipo “como Glue Job, preciso assumir a execution role…”

B) Não é persona: só o Engenheiro e o Analista/BI são personas; o Glue Job entra nos critérios de aceite da história da role de Glue

X) Other (please describe after [Answer]: tag below)

[Answer]:B	Glue Job não é persona; vira critério de aceite

---

## Question 4
Como tratar o Projeto 2 (consumidor dos ARNs)?

A) Persona “Plataforma de dados (Projeto 2)” com história própria de consumo do contrato de outputs

B) Sem persona extra: o contrato (`glue_role_arn`, `analytics_role_arn`, `access_role_arn = null`) fica como critérios de aceite na história de outputs do Engenheiro

X) Other (please describe after [Answer]: tag below)

[Answer]:B	Projeto 2 é contrato nos outputs, não persona

---

## Question 5
Formato dos critérios de aceite?

A) Given / When / Then (Gherkin)

B) Checklist testável (bullets verificáveis: apply, output, simulate, destroy)

C) Gherkin para jornadas de assume-role; checklist para provisionamento Terraform

X) Other (please describe after [Answer]: tag below)

[Answer]:C	Gherkin para assume-role, checklist para provisionar

---

## Question 6
Onde colocar os cenários negativos (negar acesso a buckets fora da POC)?

A) História dedicada de menor privilégio / negação (RF7)

B) Critérios negativos dentro de cada história de role (Glue e Analytics)

C) Ambos: critérios negativos em cada role **e** uma história de validação RF7 que amarra o `simulate-principal-policy`

X) Other (please describe after [Answer]: tag below)

[Answer]:C	Negação em cada role e história RF7 transversal

---

## Question 7
O output `access_role_arn = null` deve ser história própria ou parte do contrato de outputs?

A) História própria (deixa explícito que a role de Acesso está fora desta POC)

B) Um critério de aceite na história de outputs / contrato

X) Other (please describe after [Answer]: tag below)

[Answer]:B	access_role_arn = null é critério, não história

---

## 4. Checklist de execução (Parte 2 — após aprovação)

- [x] Carregar `requirements.md` e este plano aprovado
- [x] Gerar `personas.md` com as personas definidas pelas respostas (arquétipo, objetivos, dores, histórias associadas)
- [x] Mapear cada persona às histórias correspondentes
- [x] Gerar `stories.md` com a decomposição e granularidade aprovadas
- [x] Garantir INVEST em cada história (Independent, Negotiable, Valuable, Estimable, Small, Testable)
- [x] Incluir critérios de aceite no formato aprovado, rastreáveis a RF/RNF
- [x] Incluir cenário de `access_role_arn = null` conforme a pergunta 7
- [x] Incluir cenários negativos de menor privilégio conforme a pergunta 6
- [x] Revisar cobertura: RF1–RF7 e RNF relevantes sem vazamento de implementação Terraform
- [x] Atualizar checkboxes deste plano e `aidlc-state.md`

---

## 5. Regras da geração (pré-aprovadas, não negociáveis)

- Idioma: português
- Sem cronograma, sprint ou lista de resources AWS neste estágio
- Histórias descrevem **o que** o ator obtém, não **como** o HCL é escrito
- Extensões Security / Resiliency / PBT: N/A (desabilitadas); menor privilégio via RF7/RNF3 nas histórias
