# NFR Design Patterns — u3-identity-ci

## Resiliência

- **Retry pontual:** 3 tentativas com sleep em `aws-actions/configure-aws-credentials` e no primeiro `terraform init` se `AccessDenied` / not authorized (OIDC/IAM eventual consistency após o bootstrap).
- **Lock:** DynamoDB nativo do backend Terraform. Sem `force-unlock` no CI.
- **Artifact `tfplan`:** se o job apply não encontrar o artifact, o job **falha**; re-run manual do workflow.
- Sem circuit breaker, fila, multi-AZ.

## Escalabilidade

- Três callers independentes; concurrency `identity-{env}` com `cancel-in-progress: false`.
- Sem `strategy.matrix`. Limite da POC: três ambientes.

## Desempenho

- Sem `actions/cache` de providers. Cada job: `terraform init` limpo.
- `timeout-minutes: 20` por job (já NFR).

## Segurança

- Artifact `tfplan`: privado do run, **`retention-days: 1`**.
- Reusable workflow: **sem** `secrets: inherit`. AWS via OIDC + vars do GitHub Environment (`AWS_ROLE_ARN`, região).
- `permissions` declaradas no reusable **e** nos callers: `contents: read`, `id-token: write` (o GHA usa a interseção).
- Job apply: `actions: read` para baixar o artifact. Sem `pull_request` apply. Sem access keys.

## Extensões

Security Baseline, Resiliency Baseline e PBT: **N/A**.
