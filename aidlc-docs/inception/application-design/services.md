# Services — InfraRoles Mini

## IdentityPlatform

| Campo | Valor |
|-------|--------|
| Tipo | Serviço lógico (Q3-A) |
| Implantação | Um único `terraform apply` no root module |
| Camada extra? | Não (Q7-A). É o **rótulo** do apply coeso, não uma fachada na frente dos componentes |

### Responsabilidades

- Orquestrar em um apply: suporte bootstrap + `GlueIdentity` + `AnalyticsIdentity` + `OutputContract`
- Expor o ciclo `plan` / `apply` / `output` / `destroy`
- Carregar variáveis compartilhadas (naming, região, buckets, principais de Analytics) e injetá-las nas identidades — **sem** criar dependência IAM entre as roles
- Não criar buckets, jobs Glue, grants Lake Formation nem a role de Acesso

### Orquestração

```
IdentityPlatform.apply
    |
    +-- bootstrap (suporte): provider, versions, vars, tags, backend local
    +-- GlueIdentity.configure(...)     --> glue_role_arn
    +-- AnalyticsIdentity.configure(...) --> analytics_role_arn
    +-- OutputContract.bind(glue, analytics) --> outputs (+ access_role_arn = null)
```

As duas identidades rodam no mesmo apply, em paralelo lógico: nenhuma espera o ARN da outra (Q4-A). O contrato só **lê** os ARNs depois que as identidades existem no mesmo grafo.

### Interações externas

| Quem | Como |
|------|------|
| P1 Engenheiro | Opera o serviço (`apply` / `output` / `destroy`) |
| Projeto 2 | Lê só o `OutputContract` |
| Glue Job, P2, Não-consumidor | Não chamam o serviço; assumem roles já provisionadas (aceite / US-5 em Build and Test) |

### Serviços que não existem

- Serviço Glue vs serviço Analytics separados (rejeitado Q3-C)
- Serviço de verificação (rejeitado Q6-B)
