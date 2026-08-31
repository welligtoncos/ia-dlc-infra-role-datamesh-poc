# Code Generation Summary — u3-identity-ci

## Created

- `identity/env/dev.tfvars`, `hom.tfvars`, `prod.tfvars` (após reorganização: pasta `identity/`)
- `identity/env/*.backend.hcl`
- `.github/workflows/deploy-identity.yml` (reusable; `working-directory: identity`)
- `.github/workflows/deploy-dev.yml`, `deploy-hom.yml`, `deploy-prod.yml`

## Modified

- `.gitignore` — `!identity/env/*.tfvars` + `!identity/example.tfvars`
- `identity/versions.tf` — `backend "s3" {}`
- `identity/variables.tf` — validation `environment` ∈ {dev, hom, prod}
- `identity/example.tfvars` — copiar de `env/*.tfvars`
- `README.md` — pipelines, hom, migrate, var-file, simulate; layout `identity/`
- `bootstrap/locals.tf` + `bootstrap/iam.tf` — trust OIDC também `ref:refs/heads/{branch}` (job plan hom/prod sem Environment). Exceção ao “não regenerar bootstrap”: sem isso o plan job falha AssumeRole.
- `bootstrap/README.md` — trust atualizado

## Not modified

- `glue.tf`, `analytics.tf`, `outputs.tf`, `provider.tf`
- `tests/simulate-principal-policy.sh` / `.ps1`

## Validate

`terraform fmt`; `terraform init -backend=false`; `terraform validate` em `identity/` OK. `bootstrap/` validate OK.

## Notas

- Job apply hom/prod: `terraform init -input=false -backend-config=${{ inputs.backend_path }}` (mesmo path do plan).
- `sor_bucket` via awk no tfvars (melhoria futura: output).
- Vars GitHub: `AWS_ROLE_ARN_DEV` / `_HOM` / `_PROD` + `AWS_REGION` (repositório).
