# NFR Design Patterns — u2-bootstrap

## Resiliência

- **Retry nativo** do provider Terraform/AWS no `apply` local. Sem wrapper.
- **State da U3:** `lifecycle.prevent_destroy = true` no bucket S3 e na tabela DynamoDB. Destroy real exige remover o lifecycle (ato consciente).
- **Ordem:** README: não destruir bootstrap com state U3 ainda em uso.
- Sem circuit breaker, fila, multi-AZ, CRR.

## Escalabilidade

- Root plano; nomes `{project_prefix}-{environment}-…` (um bucket, uma tabela, um OIDC provider, uma role por conta).
- Sem `bootstrap/modules/`.

## Desempenho

- Nenhum. One-shot. Wait de OIDC/IAM, se necessário, é da **U3**.

## Segurança

- Trust da deploy role: `aud` = `sts.amazonaws.com`; `sub` StringLike `repo:<owner>/<repo>:environment:<env>`.
- S3: Block Public Access, SSE-S3, versionamento, bucket policy (deploy role + admin).
- **`force_destroy = false`** (não esvaziar state no destroy).
- Thumbprint OIDC GitHub: constante documentada (sem provider `tls`).
- Sem KMS CMK.

## Extensões

Security Baseline, Resiliency Baseline e PBT: **N/A**.
