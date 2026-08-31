# NFR Requirements Plan — u2-bootstrap

**Estágio**: CONSTRUCTION — Requisitos NFR (planejamento)
**Unidade**: `u2-bootstrap`
**Design funcional**: SKIP (execution-plan). Base: `requirements.md` RF-ME3, `components.md` BootstrapStack, `unit-of-work.md`.
**Já fechado**: Terraform `>= 1.7.5`, AWS `~> 5.0`, OIDC sem access keys, state do bootstrap **local**, extensões Security/Resiliency/PBT desabilitadas. Apply **não** no CI.

Preencha cada `[Answer]:`. Artefatos em `aidlc-docs/construction/u2-bootstrap/nfr-requirements/` só após as respostas.

Usabilidade de UI: **N/A**.

---

## Question 1
Escalabilidade: o bootstrap precisa além de **uma** instância S3+DDB+OIDC+role **por conta** (3 contas no máximo desta POC)?

A) Não — uma stack por conta; sem multi-região, sem vários backends na mesma conta

B) Sim — permitir prefixos/múltiplos backends na mesma conta (ex.: vários projetos)

X) Other (please describe after [Answer]: tag below)

[Answer]: A — uma stack por conta, sem multi-região, sem vários backends. Três contas é o teto desta POC. Projetar para múltiplos projetos na mesma conta (B) é otimização prematura.

---

## Question 2
Desempenho: há alvo de tempo para o `apply` do bootstrap?

A) Nenhum SLO — apply one-shot de engenheiro (minutos) é aceitável

B) Apply deve completar em menos de 2 minutos em conta vazia

X) Other (please describe after [Answer]: tag below)

[Answer]: A — sem SLO. Bootstrap é one-shot de engenheiro; se demorar 3 minutos em vez de 2, ninguém nota. SLO seria métrica para manter sem retorno.

---

## Question 3
Disponibilidade do **backend que o bootstrap cria** (S3 + DynamoDB usados depois pela U3)?

A) Mínimo POC: S3 com versionamento + bloqueio de acesso público; DynamoDB `PAY_PER_REQUEST`; uma região; sem replica S3/DDB

B) A + SSE-S3 no bucket e PITR no DynamoDB

C) Multi-região / CRR — fora do espírito desta POC

X) Other (please describe after [Answer]: tag below)

[Answer]: B — S3 com versionamento + BPA + SSE-S3 no bucket + PITR no DynamoDB. Aqui é o único ponto onde eu aperto além do mínimo, e o motivo é concreto: esse bucket guarda o state de prod. Perder o state de prod significa perder o controle do que está provisionado — reimportar tudo ou limpar no console. SSE-S3 é grátis, PITR no DynamoDB custa centavos e te dá 35 dias de point-in-time recovery. CRR/multi-região (C) é overkill, mas SSE+PITR são seguros baratos que se pagam na primeira vez que algo der errado.

---

## Question 4
Segurança da deploy role e do OIDC (além de “sem access keys”)?

A) Trust OIDC restrito a **este** repositório GitHub (`sub` com `repo:ORG/REPO:*` ou por environment); bucket state só a deploy role + admin; sem KMS CMK

B) A + `sub` ainda mais estreito (só `environment:dev` etc. — três roles, uma por env, em vez de uma role por conta)

C) A + KMS CMK no bucket de state

X) Other (please describe after [Answer]: tag below)

[Answer]: B — trust OIDC restrito ao repositório e ao environment (sub com repo:ORG/REPO:environment:dev). Uma role por conta, mas o trust de cada uma aceita só o environment correspondente. Isso é o RF-ME7 (isolamento) implementado na raiz: a pipeline de dev não consegue assumir a role de prod, nem se o YAML for editado maliciosamente. Sem KMS CMK (C) — SSE-S3 já cobre; CMK adicionaria complexidade de key policy sem ganho nesta POC.

---

## Question 5
Stack: providers além de `hashicorp/aws` no root `bootstrap/`?

A) Só AWS (mesmo pin da U1: `~> 5.0`, lockfile). Thumbprint OIDC GitHub: lista documentada AWS ou `thumbprint_list` estático conhecido — sem provider `tls`

B) AWS + `hashicorp/tls` para calcular thumbprint do GitHub OIDC no apply

X) Other (please describe after [Answer]: tag below)

[Answer]: A — só AWS. O thumbprint do GitHub OIDC é um valor estático bem documentado pela AWS; calcular via hashicorp/tls (B) adiciona um provider e uma dependência de rede desnecessária. Hardcodar o thumbprint conhecido é mais simples e mais confiável para um bootstrap que roda uma vez.

---

## Question 6
Confiabilidade / observabilidade do bootstrap?

A) Sem CloudWatch/alarmes; falha = erro no CLI; README lista o que deve existir após o apply

B) A + EventBridge/CloudTrail dedicado nesta unidade

X) Other (please describe after [Answer]: tag below)

[Answer]: A — sem alarmes; falha é erro no CLI. Bootstrap é one-shot — não há o que monitorar continuamente. O README lista o que deve existir após o apply (bucket, tabela, OIDC provider, role) como checklist de confirmação.

---

## Question 7
Manutenibilidade: o que a U2 exige além de `fmt`/`validate`?

A) README em `bootstrap/` (ou seção no README raiz): apply uma vez por conta, state local gitignored, outputs a copiar para GitHub/`backend.hcl`

B) A + `example.tfvars` **dentro de** `bootstrap/` (gitignore `*.tfvars` continua; exception do example)

X) Other (please describe after [Answer]: tag below)

[Answer]: B — README + example.tfvars dentro de bootstrap/. O example.tfvars no bootstrap serve o mesmo papel que serve na raiz: mostra quais variáveis preencher (repo GitHub, região, prefixo, account ID placeholder) sem expor valores reais. Sem ele, o engenheiro tem que ler o variables.tf para saber o que passar. É uma adição mínima com valor imediato.

---

## Checklist de execução (após respostas)

- [x] Gerar `aidlc-docs/construction/u2-bootstrap/nfr-requirements/nfr-requirements.md`
- [x] Gerar `aidlc-docs/construction/u2-bootstrap/nfr-requirements/tech-stack-decisions.md`
- [x] Atualizar checkboxes e `aidlc-state.md`

---

## Regras

- Idioma: português
- Extensões: N/A
- Não especificar YAML da U3 aqui
