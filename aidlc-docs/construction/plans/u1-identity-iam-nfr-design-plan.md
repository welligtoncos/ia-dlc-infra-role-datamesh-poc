# NFR Design Plan — u1-identity-iam

**Estágio**: CONSTRUCTION — Design NFR (planejamento)
**Unidade**: `u1-identity-iam`
**Entrada**: `nfr-requirements.md` + `tech-stack-decisions.md` (POC, sem HA/CI/SLO, state local, tests/ + README).

Preencha cada `[Answer]:`. Artefatos em `nfr-design/` só após as respostas.

Sem filas, caches, circuit breakers de aplicação — esta unidade não tem runtime próprio.

---

## Question 1
Padrão de resiliência para falha de `apply` (throttling IAM, rede)?

A) Só retries padrão do provider Terraform/AWS; P1 reexecuta o comando se falhar

B) Wrapper no script `tests/` com retry/backoff de `apply` (além do simulate)

X) Other (please describe after [Answer]: tag below)

[Answer]:A	Retry nativo do provider; reexecutar apply se falhar

---

## Question 2
Padrão de escala (já fixamos 2 roles e lista pequena)?

A) Nenhum componente extra de escala; policies por identidade, sem factory/pool

B) Policy gerenciada compartilhada entre as duas roles para S3 (aumenta acoplamento — não alinhado ao design funcional)

X) Other (please describe after [Answer]: tag below)

[Answer]:	A	Policies dedicadas por identidade (sem compartilhamento)

---

## Question 3
Padrão de desempenho / consistência antes da US-5?

A) Nenhum wait; `simulate-principal-policy` logo após o apply

B) Documentar no README/script uma espera curta (IAM eventual consistency) só se o simulate falhar de forma transitória; sem SLO

X) Other (please describe after [Answer]: tag below)

[Answer]:B	Documentar espera curta p/ eventual consistency do IAM

---

## Question 4
Padrão de segurança (implementação do menor privilégio)?

A) Policies **dedicadas por identidade** (allow só no perímetro); sem AWS managed `*FullAccess`; Deny explícito extra **não** obrigatório

B) A + Deny explícito `s3:*` em recursos fora da lista de buckets da POC

C) AWS managed policies amplas (S3FullAccess / GlueConsole) para acelerar a POC

X) Other (please describe after [Answer]: tag below)

[Answer]:A	Allow-only escopado (deny-by-default); sem Deny explícito

---

## Question 5
Quais componentes lógicos NFR existem (não são roles)?

A) `GitIgnore` (state + `*.tfvars`), `ExampleTfvars`, `Lockfile`, `Readme` (US-5), `SimulateScript` em `tests/`

B) A + `Makefile` com alvos fmt/validate/plan

C) Só README; o resto fica implícito no Code Generation

X) Other (please describe after [Answer]: tag below)

[Answer]:A	GitIgnore, ExampleTfvars, Lockfile, README, SimulateScript

---

## Checklist de execução (após respostas)

- [x] Gerar `aidlc-docs/construction/u1-identity-iam/nfr-design/nfr-design-patterns.md`
- [x] Gerar `aidlc-docs/construction/u1-identity-iam/nfr-design/logical-components.md`
- [x] Atualizar checkboxes e `aidlc-state.md`

---

## Regras

- Extensões Security / Resiliency / PBT: N/A
- Sem WAF, multi-AZ, cache, fila, circuit breaker
