# Instruções de Testes de Integração

Interações **U2 → U3** (backend + OIDC) e **CI → identidade**.

## Cenários de Teste

### Cenário 1: Bootstrap cria backend que o identity init usa

- **Descrição**: outputs U2 (`state_bucket_name`, `lock_table_name`, região) coincidem com `identity/env/{env}.backend.hcl`
- **Setup**: apply `bootstrap/` na conta do env; preencher `backend.hcl` se o nome S3 foi override
- **Etapas**: em `identity/`, `terraform init -backend-config=env/{env}.backend.hcl` (admin); `plan` não deve pedir recriar o backend
- **Resultados Esperados**: init remoto OK; lock DynamoDB `LockID`
- **Limpeza**: não destruir U2 enquanto houver state da identidade

### Cenário 2: OIDC assume a deploy role da conta certa

- **Descrição**: pipeline `dev` não assume role de `prod` (RF-ME7)
- **Setup**: três Environments; vars `AWS_ROLE_ARN_*`; trust `environment:` + `ref:`
- **Etapas**: disparar `deploy-dev`; confirmar `aws sts get-caller-identity` na conta dev
- **Resultados Esperados**: Account ID da conta dev; falha se apontar ARN de outra conta
- **Limpeza**: N/A

### Cenário 3: Plan e apply usam o mesmo backend.hcl

- **Descrição**: job apply hom/prod faz `init -backend-config` com o **mesmo** `inputs.backend_path` do plan
- **Setup**: workflow `deploy-hom` / `deploy-prod`
- **Etapas**: aprovar apply após revisar o plan no log do job `plan`
- **Resultados Esperados**: apply do `tfplan` sem erro de state incompatível
- **Limpeza**: artifact `tfplan` expira em 1 dia

## Configurar Ambiente

U2 aplicada; GitHub Environments; branch `hom` publicada se for testar hom.

## Executar

Não há suite JUnit. Executar os cenários manualmente ou via `workflow_dispatch`.

Logs: GitHub Actions e CLI Terraform.

## Limpeza

Não `terraform destroy` no CI. Destroy da identidade: local. Destroy do bootstrap: só após identidade destruída e `prevent_destroy` removido.
