# NFR Requirements — u2-bootstrap

Bootstrap one-shot por conta. Sem UI. Extensões Security/Resiliency/PBT **N/A**. Design funcional SKIP; base RF-ME3.

## Escalabilidade

- Uma stack S3 + DynamoDB + OIDC provider + **uma** deploy role **por conta**.
- Teto: três contas (dev, hom, prod). Sem multi-região e sem vários backends na mesma conta.

## Desempenho

- Sem SLO de `apply`. Tempo de engenheiro (minutos) é aceitável.

## Disponibilidade / DR (recursos que a U3 usará)

- Uma região (`aws_region`, default herdado da POC: `sa-east-1`).
- S3: versionamento, Block Public Access, **SSE-S3**.
- DynamoDB: `PAY_PER_REQUEST` + **PITR** (35 dias).
- Sem CRR / multi-região.
- State do **próprio** bootstrap: local, gitignored (não é o state da U3).

## Segurança operacional

- Sem access keys no CI (já fechado).
- **Uma deploy role por conta**; trust OIDC GitHub com `sub` restrito a **este** `repo:ORG/REPO` **e** ao GitHub Environment daquele ambiente (`environment:dev` na conta dev, etc.). Pipeline de um env não assume a role de outra conta mesmo se o YAML for alterado.
- Bucket de state: acesso à deploy role + admin da conta; sem KMS CMK (SSE-S3 cobre).
- Interpretar Q4-B: **não** três roles na mesma conta; o isolamento é conta = ambiente + `sub` de environment.

## Confiabilidade / observabilidade

- Sem CloudWatch, EventBridge ou CloudTrail dedicado nesta unidade.
- Falha = erro no CLI.
- README: checklist do que deve existir após o apply (bucket, tabela, OIDC, role).

## Manutenibilidade

- `terraform fmt` / `validate` em `bootstrap/`.
- README (`bootstrap/` e/ou seção no README raiz): apply uma vez por conta, state local, outputs a copiar para GitHub vars e `env/*.backend.hcl`.
- `bootstrap/example.tfvars` commitado; `*.tfvars` gitignored com exceção do example.

## Usabilidade

- N/A para UI. Variáveis nomeadas + `example.tfvars`.

## Conformidade com extensões

| Extensão | Status |
|----------|--------|
| Security Baseline | N/A |
| Resiliency Baseline | N/A |
| Property-Based Testing | N/A |
