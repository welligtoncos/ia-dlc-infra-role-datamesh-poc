# NFR Design Plan — u2-bootstrap

**Estágio**: CONSTRUCTION — Design NFR (planejamento)
**Unidade**: `u2-bootstrap`
**Entrada**: `nfr-requirements.md` + `tech-stack-decisions.md` (uma stack/conta; SSE-S3+PITR; 1 deploy role/conta com `sub` repo+environment; só AWS; README + example.tfvars).

Preencha cada `[Answer]:`. Artefatos em `nfr-design/` só após as respostas.

Sem filas, caches, circuit breakers de aplicação — bootstrap não tem runtime contínuo.

---

## Question 1
Padrão de resiliência: `destroy` do bootstrap apaga o bucket de state da U3. Como proteger?

A) Sem `prevent_destroy` — POC deve poder destruir tudo; README avisa que destroy do bootstrap **depois** da U3 (ou com state vazio) é perigoso

B) `lifecycle { prevent_destroy = true }` no bucket S3 e na tabela DynamoDB; remover só com `-target` consciente / edição do código

X) Other (please describe after [Answer]: tag below)

[Answer]: B — prevent_destroy no bucket e na tabela DynamoDB. Aqui é a única vez neste projeto inteiro que eu recomendo prevent_destroy, e o motivo é concreto: destruir o bucket de state da U3 por acidente apaga o controle do que está provisionado em prod. O force_destroy dos buckets de dados (Projeto 2) fazia sentido porque eram dados de POC descartáveis; aqui é state de infraestrutura. Se você precisar destruir de verdade, edita o código (remove o lifecycle), aplica, e aí destrói — é um ato consciente, não um terraform destroy distraído. O README avisa, mas prevent_destroy é a guarda que funciona quando ninguém lê o README.

---

## Question 2
Padrão de escala (já uma stack por conta)?

A) Nenhum componente extra; nomes derivados de `project_prefix` + conta/environment (um bucket, uma tabela, um OIDC provider, uma role)

B) Módulo Terraform reutilizável em `bootstrap/modules/` mesmo com uma instância (overkill para POC)

X) Other (please describe after [Answer]: tag below)

[Answer]: A — nenhum componente extra; nomes derivados de project_prefix + environment. Um bucket, uma tabela, um OIDC provider, uma role. Módulo reutilizável (B) para uma instância por conta é cerimônia sem ganho — se um dia virar multi-projeto, refatora; por ora, root plano.

---

## Question 3
Padrão de desempenho?

A) Nenhum (one-shot; sem cache, sem wait de IAM além do apply)

B) Sleep documentado após criar OIDC provider (propagação) só se o primeiro assume falhar — isso é da U3, não desta unidade

X) Other (please describe after [Answer]: tag below)

[Answer]: A — nenhum padrão de desempenho. One-shot, sem cache, sem wait. Se a propagação do OIDC provider causar falha no primeiro assume da U3, isso é problema da U3 (ela que documenta o retry), não do bootstrap. Correto não misturar.

---

## Question 4
Padrão de segurança (implementação do OIDC + bucket)?

A) Condições no trust: `aud` = `sts.amazonaws.com`; `sub` StringLike `repo:<owner>/<repo>:environment:<env>`; S3 BPA + SSE-S3 + bucket policy (deploy role + admin); sem force_destroy no bucket (não apagar objetos de state no destroy sem querer)

B) A + `force_destroy = true` no bucket para facilitar teardown da POC

C) Trust só `repo:ORG/REPO:*` sem amarrar `environment:` (mais frouxo que o NFR Q4)

X) Other (please describe after [Answer]: tag below)

[Answer]: A — trust com aud + sub por environment, S3 BPA + SSE-S3 + bucket policy restrita, sem force_destroy no bucket. Isso é coerente com Q1-B: prevent_destroy protege contra destroy acidental, force_destroy = false protege contra esvaziar o bucket durante o destroy. As duas guardas juntas fazem o state de prod ser difícil de apagar por acidente — que é exatamente o comportamento correto. C (trust sem environment) violaria o RF-ME7 e o NFR Q4-B que acabamos de fechar.

---

## Question 5
Quais componentes lógicos NFR existem (não são o S3/DDB/OIDC/role em si)?

A) `BootstrapGitIgnore` (state em `bootstrap/`), `BootstrapExampleTfvars`, `BootstrapLockfile`, `BootstrapReadme` (checklist + aviso de ordem destroy), constante `OidcThumbprint`

B) A + `Makefile` em `bootstrap/`

C) Só README; o resto implícito no Code Generation

X) Other (please describe after [Answer]: tag below)

[Answer]: A — GitIgnore, ExampleTfvars, Lockfile, Readme (com checklist + aviso de ordem de destroy), constante OidcThumbprint. Makefile (B) é o mesmo argumento de sempre: duplica num terceiro lugar o que o README já documenta. Para um root de 5 resources rodado uma vez, não se paga.

---

## Checklist de execução (após respostas)

- [x] Gerar `aidlc-docs/construction/u2-bootstrap/nfr-design/nfr-design-patterns.md`
- [x] Gerar `aidlc-docs/construction/u2-bootstrap/nfr-design/logical-components.md`
- [x] Atualizar checkboxes e `aidlc-state.md`

---

## Regras

- Extensões Security / Resiliency / PBT: N/A
- Sem WAF, multi-AZ, cache, fila
- YAML da U3 fora deste estágio
