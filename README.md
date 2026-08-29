# InfraRoles Mini — Camada de Identidade (Data Mesh POC)

Terraform IAM para o **Projeto 1**: execution role Glue + role Analytics. Entrega ARNs ao Projeto 2. Nao cria buckets, jobs, workgroup nem role de Acesso.

## Requisitos

- Terraform >= 1.7.5
- AWS Provider ~> 5.0
- Credenciais AWS na default chain
- Conta com permissao para criar IAM roles/policies

## Ir ao ar

Para ir ao ar na sua conta: copie `example.tfvars` para `terraform.tfvars`, preencha ARNs e nomes de buckets, e rode `terraform apply`.

## Uso

O arquivo `terraform.tfvars` na raiz e carregado automaticamente. Nao use `-var-file=...` no PowerShell: o `-` e interpretado pelo shell e o Terraform responde `Too many command line arguments`.

```powershell
Copy-Item example.tfvars terraform.tfvars
# edite nomes de buckets, workgroup e analytics_principal_arns (ARNs reais da SUA conta)

terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
terraform output
```

Se precisar passar o arquivo explicitamente no PowerShell:

```powershell
terraform plan '-var-file=terraform.tfvars'
# ou
terraform plan --% -var-file=terraform.tfvars
```

Outputs: `glue_role_arn`, `analytics_role_arn`, `access_role_arn` (sempre `null`).

Destroy (nao apaga buckets do Projeto 2):

```powershell
terraform destroy
```

## Validacao US-5

Apos o apply, na raiz do repo:

```powershell
.\tests\simulate-principal-policy.ps1 -SorBucket "seu-bucket-sor"
```

Se o simulate falhar imediatamente apos o apply, aguarde 10–20 s (eventual consistency do IAM) e repita. Sem SLO.

O Nao-consumidor (ARN fora de `analytics_principal_arns`) nao deve conseguir `sts:AssumeRole` na role Analytics.

## Ordem com o Projeto 2

Esta identidade pode ser aplicada **antes** dos buckets existirem. Nomes devem coincidir — ver `aidlc-docs/construction/shared-infrastructure.md`.

State e `*.tfvars` reais nao entram no git (`example.tfvars` e a excecao).
