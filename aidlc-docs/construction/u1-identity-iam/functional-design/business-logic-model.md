# Business Logic Model — u1-identity-iam

Unidade: Camada de Identidade. Sem UI. Sem persistência de dados de negócio além do estado de provisionamento.

## Fluxo principal — provisionar

```
P1 informa parametros
    |
    v
Validar analytics_principal_arns (nao vazia; cada ARN e user/role IAM da mesma conta)
    |
    | falha -> nao provisiona
    v
Materializar GlueIdentity (nome, trust Glue+conta, perimetro S3/catalogo/LF/logs)
Materializar AnalyticsIdentity (nome, trust lista, perimetro leitura + Athena workgroup + resultados)
Materializar OutputContract (ARNs + access_role_arn = nulo)
    |
    v
Identidades existem mesmo se buckets ainda nao existirem (perimetro por nome)
```

## Fluxo — consumo Glue (ator de aceite)

```
Glue Job pede assume da GlueIdentity
    |
    | trust: so servico Glue e conta da POC
    v
Job le/grava/lista objetos nas camadas (sem delete)
Job le catálogo; cria/atualiza so partitions (tabelas/schema sao IaC)
Job obtem data access LF; escreve logs de execucao
Acesso a bucket fora do perimetro -> negado
```

## Fluxo — consumo Analytics

```
P2 (ARN na lista) assume AnalyticsIdentity -> permitido
Nao-consumidor assume -> negado
P2 lista/le camadas; executa query no workgroup parametrizado; grava so no bucket de resultados
P2 nao grava nem apaga nas camadas
```

## Fluxo — contrato e teardown

```
P1 le OutputContract -> glue_role_arn, analytics_role_arn, access_role_arn=nulo
Projeto 2 consome so o contrato
P1 destroi a unidade -> some identidades e policies; buckets do Projeto 2 permanecem
```

## Transformações

| Entrada | Saída |
|---------|--------|
| prefix, env, nomes de buckets, lista de principais, workgroup Athena | duas identidades nomeadas + contrato de ARNs |
| lista vazia ou ARN inválido | falha de provisionamento (nada parcialmente “válido” como contrato) |

## Persistência

- Estado de provisionamento local (detalhe de backend = NFR/infra)
- Não persiste segredos no repositório
- Não cria objetos nas camadas
