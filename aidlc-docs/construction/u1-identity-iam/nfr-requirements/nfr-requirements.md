# NFR Requirements — u1-identity-iam

POC de identidade IAM. Sem UI. Extensões Security Baseline, Resiliency e PBT **N/A**.

## Escalabilidade

- Duas roles fixas; lista de principais da ordem de **dezenas**, não centenas.
- Sem autoscaling, sharding de policies ou desenho para growth.

## Desempenho

- Sem SLO numérico de `plan`/`apply`/assume.
- Apply em tempo de engenheiro (minutos) é aceitável. Latência de AssumeRole é a do IAM da AWS.

## Disponibilidade / DR

- Uma região (`aws_region`, default `sa-east-1`).
- Sem HA, failover ou RTO/RPO formais.
- State **local** no disco do P1; **cópia manual opcional** (backup informal). Sem backend S3/DynamoDB.

## Segurança operacional

- Menor privilégio e fail-fast de ARNs: design funcional.
- `.gitignore`: state, backups de state, `*.tfvars` (inclui `terraform.tfvars`).
- `example.tfvars` commitado com placeholders (sem Account IDs/ARNs reais).
- Sem encriptação extra do state local.

## Confiabilidade / observabilidade

- Sem alarmes CloudWatch nesta unidade.
- Falhas visíveis no CLI.
- README descreve como validar US-5 (`simulate-principal-policy`, P2 vs Não-consumidor).

## Manutenibilidade

- Barra: `terraform fmt` e `terraform validate`.
- Script em `tests/` documenta/executa os comandos de simulação IAM (sem CI).
- README: apply, output, destroy, simulate.

## Usabilidade

- N/A para UI. Usabilidade = variáveis nomeadas + example.tfvars + README.

## Conformidade com extensões

| Extensão | Status |
|----------|--------|
| Security Baseline | N/A |
| Resiliency Baseline | N/A |
| Property-Based Testing | N/A |
