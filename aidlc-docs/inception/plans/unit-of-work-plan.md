# Unit of Work Plan — InfraRoles Mini

**Estágio**: INCEPTION — Geração de Unidades (Parte 1: Planejamento)
**Fontes**: design da aplicação (`IdentityPlatform` = um apply), US-1 a US-6, execution-plan (rascunho U1)

Preencha cada `[Answer]:`. A Parte 2 (gerar `unit-of-work.md`, dependências e story-map) só começa após as respostas **e** a aprovação explícita deste plano.

## Decisões resolvidas (respostas)

| Q | Decisão |
|---|---------|
| 1 | Uma unidade `u1-identity-iam` (US-1 a US-6). *Parse: `[Answer]:` vazio; `---A` imediatamente abaixo tratado como A.* |
| 2 | Não se aplica split de state — uma unidade, um `apply` |
| 3 | Um dono (P1), uma unidade |
| 4 | Um `apply` / um `destroy` |
| 5 | Um bounded context: Camada de Identidade |
| 6 | Arquivos `.tf` na raiz do repositório (não `src/`, não `terraform/`) |

**Unidade a gerar:** `u1-identity-iam` = Serviço `IdentityPlatform`. Módulos lógicos internos: GlueIdentity, AnalyticsIdentity, OutputContract. Bootstrap = suporte. Construction: um loop. Código na raiz do workspace.

---

## Contexto já fechado

- Um root Terraform; `glue.tf` + `analytics.tf`; sem submódulo
- Três componentes lógicos num único serviço `IdentityPlatform`
- Roles sem dependência IAM entre si
- US-5 = Build and Test, não componente
- POC pessoal (P1 opera o apply)

**Terminologia:** Unidade de Trabalho = agrupamento de histórias para o loop de Construction. Serviço = `IdentityPlatform` (um apply). Módulos lógicos = GlueIdentity / AnalyticsIdentity / OutputContract **dentro** da unidade, se a unidade for única.

---

## Question 1
Como agrupar as histórias em unidades de trabalho? (afinidade US-1..US-6 vs um apply só)

A) Uma unidade `u1-identity-iam`: US-1 a US-6 no mesmo loop de Construction (alinhado ao `IdentityPlatform`)

B) Duas unidades sequenciais: `u1-glue-identity` (US-1, parte de US-4/US-6) e `u2-analytics-contract` (US-2, US-3, resto de US-4/US-5/US-6)

C) Três unidades espelhando componentes: Glue, Analytics, OutputContract — US-4/US-5/US-6 numa quarta unidade de plataforma

X) Other (please describe after [Answer]: tag below)

[Answer]:

---A

## Question 2
Se houver mais de uma unidade, como tratar o estado Terraform e as variáveis compartilhadas?

A) Não se aplica — uma unidade, um state, um `apply`

B) Duas unidades, **mesmo** state/root (só fatia o loop de design/código; o apply continua único)

C) Duas unidades com states separados (dois `apply`) — não recomendado para esta POC

X) Other (please describe after [Answer]: tag below)

[Answer]:	A

---

## Question 3
Ownership das unidades (equipe)?

A) Uma pessoa (P1): uma unidade, um dono

B) Uma pessoa, mas loops de Construction separados por role (mesmo dono, duas unidades de trabalho)

X) Other (please describe after [Answer]: tag below)

[Answer]:A

---

## Question 4
Implantação / ciclo de vida: as identidades Glue e Analytics precisam de `apply` ou escala independentes nesta POC?

A) Não — um `apply` / um `destroy` para as duas (US-6 único)

B) Sim — poder aplicar só Glue ou só Analytics (exigiria split de state ou `-target`, fora do espírito do contrato único)

X) Other (please describe after [Answer]: tag below)

[Answer]:A

---

## Question 5
Bounded context de negócio?

A) Um contexto: Camada de Identidade da malha (todas as histórias)

B) Dois contextos: execução ETL (Glue) vs consumo analítico (Analytics + contrato)

X) Other (please describe after [Answer]: tag below)

[Answer]:A

---

## Question 6
Onde colocar o código Terraform na raiz do workspace? (greenfield; o padrão genérico `src/`/`tests/`/`config/` não é idiomático para IaC)

A) Arquivos `.tf` na raiz do repositório (`versions.tf`, `variables.tf`, `provider.tf`, `glue.tf`, `analytics.tf`, `outputs.tf`, `.gitignore`) — testes de validação em `tests/` se existirem

B) Tudo sob `terraform/` na raiz (`terraform/glue.tf`, etc.)

C) Seguir `src/` + `tests/` + `config/` mesmo sendo Terraform

X) Other (please describe after [Answer]: tag below)

[Answer]:	A

---

## Checklist de execução (Parte 2 — após aprovação)

- [x] Carregar design, stories e este plano aprovado
- [x] Gerar `aidlc-docs/inception/application-design/unit-of-work.md` (unidades, responsabilidades, organização de código greenfield)
- [x] Gerar `aidlc-docs/inception/application-design/unit-of-work-dependency.md`
- [x] Gerar `aidlc-docs/inception/application-design/unit-of-work-story-map.md` (todas as US-1..US-6 atribuídas)
- [x] Validar limites: um vs N applies; sem role de Acesso; US-5 na unidade que fará Build and Test
- [x] Atualizar checkboxes e `aidlc-state.md`

---

## Regras da geração

- Idioma: português
- Unidade única ⇒ Serviço IdentityPlatform; componentes = módulos lógicos internos
- Multi-unidade ⇒ declarar dependências de state/variáveis explicitamente
- Extensões Security / Resiliency / PBT: N/A
