# Logical Components — u3-identity-ci

Componentes lógicos **NFR** (não são as roles Glue/Analytics). Sem fila, cache ou circuit breaker de aplicação. Sem Composite Action extra.

| Componente | Responsabilidade |
|------------|------------------|
| ReusableDeployWorkflow | fmt-check → OIDC (retry) → init `-backend-config` → validate → plan `-out` → (hom/prod: upload artifact; job apply) apply `tfplan` → simulate.sh |
| DeployCallerDev | `on:` push `dev` + dispatch; um job; sem Environment de aprovação; inputs env=`dev` |
| DeployCallerHom | `on:` push `hom` + dispatch; job plan + job apply com Environment `hom` |
| DeployCallerProd | `on:` push `main` + dispatch; job plan + job apply com Environment `prod` |
| EnvTfvars | `env/{dev,hom,prod}.tfvars` commitados (placeholders) |
| BackendHcl | `env/{dev,hom,prod}.backend.hcl` (bucket, table, key, region) |
| IdentityBackendPartial | Bloco `backend "s3" {}` vazio no root U1 |
| EnvironmentValidation | `variable.environment` ∈ {dev, hom, prod} |
| ConcurrencyGroup | `identity-{env}`; sem cancel-in-progress |
| GitIgnoreEnvTfvarsAllow | `.gitignore` ignora `*.tfvars` mas **não** `env/*.tfvars` |
| IdentityCiReadme | Branch `hom`; bootstrap → Environments; local vs CI var-file; `.ps1` vs `.sh` |

## Integração

```
Caller (dev|hom|prod)
  -> ReusableDeployWorkflow
       -> OIDC retry -> terraform init (BackendHcl)
       -> plan -out (EnvTfvars)
       -> [hom/prod] artifact tfplan 1d -> apply job (Environment)
       -> [dev] apply tfplan no mesmo job
       -> simulate.sh (fail job se != 0)
ConcurrencyGroup impede dois applies no mesmo env
GitIgnoreEnvTfvarsAllow versiona env/*.tfvars
IdentityBackendPartial + EnvironmentValidation no root U1
```

## Fora deste desenho

- Composite Action
- `strategy.matrix`
- Cache de providers
- `secrets: inherit` / access keys
- force-unlock no CI
- Reescrita de glue.tf / analytics.tf
