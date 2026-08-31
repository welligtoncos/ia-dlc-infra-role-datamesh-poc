# Code Generation Summary — u2-bootstrap

## Created (workspace `bootstrap/`)

- `versions.tf`, `provider.tf`, `data.tf`, `locals.tf`, `variables.tf`
- `example.tfvars`
- `s3.tf` (bucket, versioning, SSE-S3, BPA, Deny HTTP)
- `dynamodb.tf` (PAY_PER_REQUEST, LockID, PITR, prevent_destroy)
- `oidc.tf` (GitHub OIDC, thumbprints estáticos)
- `iam.tf` (deploy role + customer managed policy)
- `outputs.tf`
- `README.md`
- `.terraform.lock.hcl` (se `terraform init` ok)

## Modified (raiz)

- `.gitignore` — `!bootstrap/example.tfvars`
- `README.md` — seção bootstrap / multi-env

## Not created (fora do plano)

- `.github/workflows/`, `identity/env/*.tfvars`, backend S3 no root `identity/`
- `hashicorp/tls`, KMS CMK, Glue/Analytics neste diretório

## Lockfile / validate

`.terraform.lock.hcl` gerado (`hashicorp/aws` v5.100.0). `terraform fmt` e `terraform validate` OK em `bootstrap/`.

## Teste real (engenheiro)

`plan` + `apply` numa conta de teste **antes** de tratar o bootstrap como pronto. Fallback de `AccessDenied` na bucket policy: ver `bootstrap/README.md`.
