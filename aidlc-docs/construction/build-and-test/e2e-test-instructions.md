# Instruções de Testes End-to-End

Fluxo de operador (não há UI).

## Cenário: uma conta (ex. dev)

1. Aplicar `bootstrap/` (admin, state local).
2. Copiar outputs para GitHub (`AWS_ROLE_ARN_DEV`, `AWS_REGION`) e conferir `identity/env/dev.backend.hcl`.
3. Se state local da identidade existir: em `identity/`, `terraform init -backend-config=env/dev.backend.hcl -migrate-state`.
4. Local: em `identity/`, `Copy-Item env\dev.tfvars terraform.tfvars` → `plan` / `apply`; **ou** push na branch `dev` (pipeline).
5. Em `identity/`: `..\tests\simulate-principal-policy.ps1 -SorBucket "<sor>"` (local) ou o `.sh` no CI.
6. Conferir `terraform output` (contrato Projeto 2).
7. Destroy da identidade: **local**, não no CI. Não destruir bootstrap com state remoto ainda em uso.

## Hom / prod

Publicar `origin/hom` antes do primeiro push hom. Aprovar o GitHub Environment no job `apply` depois de ler o plan.

## Isolamento

Não disparar os três workflows no mesmo evento. Concurrency `identity-{env}` sem cancelar run em andamento.
