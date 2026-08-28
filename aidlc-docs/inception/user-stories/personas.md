# Personas — InfraRoles Mini

Fonte: `requirements.md` §2 e plano aprovado (`story-generation-plan.md`). Glue Job, Projeto 2 e Não-consumidor **não** são personas.

**Regra de mapa:** cada história tem **uma persona-dona**. Atores de sistema aparecem só em critérios de aceite e não entram na coluna de histórias da persona.

---

## P1 — Engenheiro de dados

| Campo | Descrição |
|-------|-----------|
| Arquétipo | Dono da POC: provisiona, valida e destrói a camada de identidade |
| Contexto | Conta AWS pessoal, ambiente `dev`, Terraform local |
| Objetivos | Roles reproduzíveis; menor privilégio; ARNs estáveis para o Projeto 2; `apply`/`destroy` limpos |
| Dores | Policies com `*` injustificado; trust que impede assume; nomes desalinhados do Projeto 2; state ou tfvars reais no git |
| Capacidades | Aplica Terraform; assume a role de Analytics para smoke test; roda `simulate-principal-policy`; usa P2 como controle positivo e o Não-consumidor como controle negativo na US-5 |
| Histórias (dona) | US-1, US-3, US-4, US-5, US-6 |

US-2 **não** pertence à P1: o consumo via Athena é da P2. Na US-1 a P1 é dona (cria a role); o Glue Job só exerce o critério de aceite.

---

## P2 — Analista / BI

| Campo | Descrição |
|-------|-----------|
| Arquétipo | Consumidor de dados da malha (leitura governada) |
| Contexto | Identidade IAM da mesma conta (user ou role) listada em `analytics_principal_arns` |
| Objetivos | Consultar `sor` / `sot` / `spec` via Athena sem escrever nas camadas |
| Dores | Sem role de leitura; trust que não inclui sua identidade; permissão de escrita indevida nas camadas |
| Capacidades | Assume a role de Analytics; executa e acompanha queries Athena; grava só no bucket de resultados; na US-5 é o **controle positivo** (ARN na lista — assume e consulta devem ser permitidos). Não executa `simulate-principal-policy` (isso é P1). O cenário de query/assume **negado** não usa a P2 — usa o Não-consumidor |
| Histórias (dona) | US-2 |

---

## Atores de sistema (não-personas)

Usados apenas em critérios de aceite. Não possuem histórias próprias.

| Ator | Papel | Onde |
|------|--------|------|
| Glue Job / Crawler | Assume a execution role criada pela P1 | US-1 (aceite de uso) |
| Projeto 2 | Consome outputs `glue_role_arn`, `analytics_role_arn`, `access_role_arn` | US-3 |
| Não-consumidor | Identidade IAM da mesma conta cujo ARN **não** está em `analytics_principal_arns`. Controle negativo de governança: assume da role Analytics deve ser negado; query/grant sobre as camadas deve ser negado | US-5 (e cenário de assume negado já esboçado na US-2) |

---

## Mapa persona-dona → histórias

| Persona | Histórias de que é dona |
|---------|-------------------------|
| P1 Engenheiro de dados | US-1, US-3, US-4, US-5, US-6 |
| P2 Analista / BI | US-2 |

## Mapa história → dono vs atores de aceite

| História | Persona-dona | Atores de aceite (não-personas) |
|----------|--------------|----------------------------------|
| US-1 | P1 Engenheiro | Glue Job / Crawler |
| US-2 | P2 Analista / BI | — (Não-consumidor só reforçado na US-5) |
| US-3 | P1 Engenheiro | Projeto 2 |
| US-4 | P1 Engenheiro | — |
| US-5 | P1 Engenheiro | P2 como controle positivo; Não-consumidor como controle negativo |
| US-6 | P1 Engenheiro | — |
