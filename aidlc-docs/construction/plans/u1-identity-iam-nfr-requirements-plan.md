# NFR Requirements Plan — u1-identity-iam

**Estágio**: CONSTRUCTION — Requisitos NFR (planejamento)
**Unidade**: `u1-identity-iam`
**Já fechado**: Terraform `>= 1.7.5`, AWS Provider `~> 5.0`, região default `sa-east-1`, state local, extensões Security/Resiliency/PBT desabilitadas, menor privilégio via regras funcionais.

Preencha cada `[Answer]:`. Artefatos em `nfr-requirements/` só após as respostas.

Usabilidade de UI: **N/A** (sem frontend).

---

## Question 1
Escalabilidade: esta unidade precisa suportar crescimento além de 2 roles e uma lista curta de principais?

A) Não — POC fixa (2 roles; lista de ARNs pequena, dezenas no máximo)

B) Sim — a lista de principais pode crescer (centenas); o desenho NFR deve evitar policies gigantes sem necessidade

X) Other (please describe after [Answer]: tag below)

[Answer]:A	Escala fixa de POC (sem projetar p/ centenas)

---

## Question 2
Desempenho: há alvo de tempo para `plan`/`apply` ou para o assume das roles?

A) Nenhum SLO numérico — apply em tempo de engenheiro (minutos) é aceitável; IAM gerenciado pela AWS

B) Apply deve completar em menos de 2 minutos em conta vazia de identidade desta POC

X) Other (please describe after [Answer]: tag below)

[Answer]:A	Sem SLO numérico

---

## Question 3
Disponibilidade / DR: o que vale para state e região?

A) Sem HA/DR — uma região (`aws_region`), state local no disco do P1, backup informal

B) State local + cópia manual opcional (P1); ainda sem backend remoto

C) Subir para S3+lock nesta unidade (contraria decisão de requirements Q9-A — só se você quiser reabrir)

X) Other (please describe after [Answer]: tag below)

[Answer]:B	State local + cópia manual (sem backend remoto)

---

## Question 4
Segurança operacional (além do menor privilégio já no design funcional)?

A) Só o já definido: gitignore de state/`*.tfvars` reais, placeholders no exemplo, tags, SourceAccount, fail-fast de ARNs

B) A + recusar `terraform.tfvars` no git via `.gitignore` explícito e `example.tfvars` commitado

C) A + B + encriptar o state local (não usual; complicado para POC)

X) Other (please describe after [Answer]: tag below)

[Answer]:B	.gitignore de *.tfvars + example.tfvars commitado

---

## Question 5
Stack: confirmar versões e artefatos de lock?

A) Manter `required_version >= 1.7.5`, `hashicorp/aws ~> 5.0`, commitar `.terraform.lock.hcl`

B) Pin exato de Terraform `1.7.5` (não `>=`)

C) AWS Provider `>= 5.0` (mais largo que `~> 5.0`)

X) Other (please describe after [Answer]: tag below)

[Answer]:A	>= 1.7.5, ~> 5.0, lock file commitado

---

## Question 6
Confiabilidade / observabilidade desta unidade?

A) Sem alarmes CloudWatch — falha visível no CLI (`apply`/`simulate`); sem monitoramento contínuo

B) Log de apply no CLI apenas; documentar no README como validar US-5

X) Other (please describe after [Answer]: tag below)

[Answer]:B	Sem alarme; README documenta a validação US-5

---

## Question 7
Manutenibilidade / verificação no repo?

A) `terraform fmt` + `terraform validate` como barra mínima; README com apply/output/destroy/simulate

B) A + script `tests/` que documenta os comandos `simulate-principal-policy` (não CI)

C) A + B + workflow CI (GitHub Actions) nesta POC

X) Other (please describe after [Answer]: tag below)

[Answer]:B	fmt/validate + script tests/, sem CI

---

## Checklist de execução (após respostas)

- [x] Gerar `aidlc-docs/construction/u1-identity-iam/nfr-requirements/nfr-requirements.md`
- [x] Gerar `aidlc-docs/construction/u1-identity-iam/nfr-requirements/tech-stack-decisions.md`
- [x] Atualizar checkboxes e `aidlc-state.md`

---

## Regras

- Extensões Security / Resiliency / PBT: N/A — não exigir WAF, multi-AZ, PBT
- Não reabrir role de Acesso nem buckets criados aqui
