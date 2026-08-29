# InfraRoles Mini — Camada de Identidade (Data Mesh POC)

> **Para que serve:** metade **identidade** do mesh — cria as roles IAM (Glue + Analytics) que o
> Projeto 2 consome. Sozinho não faz nada útil; é a fundação de acesso sobre a qual a plataforma
> de dados (`ia-dlc-datamesh-platform-poc`) aplica a governança. Os dois juntos formam o mesh.

Terraform IAM para o **Projeto 1**: execution role Glue + role Analytics. Entrega ARNs ao Projeto 2. Não cria buckets, jobs, workgroup nem role de Acesso.

## O que cria e para quem serve

Este repo **produz** duas roles; ele não consome ARNs de fora. Nomes padrão
`{project_prefix}-{environment}-glue-role` / `-analytics-role` (default `datamesh-poc-dev-…`).

| Role criada | Quem assume | Permissão IAM (este repo) |
|-------------|-------------|---------------------------|
| Glue | Serviço Glue (`glue.amazonaws.com` + `aws:SourceAccount`) | R/W/list nas três camadas (`sor`, `sot`, `spec`); **sem** `DeleteObject`. Catálogo: Get + partições (schema é IaC do Projeto 2). O fluxo “lê SOR, grava SOT/SPEC” é do job no Projeto 2, não desta policy. |
| Analytics | ARNs em `analytics_principal_arns` | List/read nas camadas; R/W **somente** no bucket de resultados Athena; Athena só no `athena_workgroup`. |

Entradas: `analytics_principal_arns` (**quem** assume a Analytics; tem de ser da **mesma conta** — o `plan` avisa se não for) e os nomes de buckets/workgroup (para **escopar** as policies — os recursos nascem no Projeto 2).

Saídas (contrato com o Projeto 2): `glue_role_arn`, `analytics_role_arn`, `access_role_arn` (sempre `null`). Confira com `terraform output` após o apply.

## Requisitos

- Terraform >= 1.7.5
- AWS Provider ~> 5.0
- Credenciais AWS na default chain
- Conta com permissão para criar IAM roles/policies

## Ir ao ar

Copie `example.tfvars` para `terraform.tfvars`, preencha `analytics_principal_arns` (ARNs reais da
SUA conta) e os nomes de buckets/workgroup, e rode `terraform apply`.

## Uso

O arquivo `terraform.tfvars` na raiz é carregado automaticamente. Não use `-var-file=...` no PowerShell: o `-` é interpretado pelo shell e o Terraform responde `Too many command line arguments`.

```powershell
Copy-Item example.tfvars terraform.tfvars
# edite analytics_principal_arns (quem assume a role Analytics) e nomes de buckets/workgroup

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

Destroy (não apaga buckets do Projeto 2):

```powershell
terraform destroy
```

## Papéis (quem testa o quê)

| Papel | Quem | O que faz |
|-------|------|-----------|
| Engenheiro | User/role que roda o Terraform | `apply` / `destroy` / `output` deste repo |
| Analista (P2) | ARN em `analytics_principal_arns` | Assume a `analytics-role` (consumo é validado no Projeto 2) |
| Glue Job | Serviço Glue | Assume a `glue-role` (usado pelo job do Projeto 2) |
| Fora do trust | ARN **fora** de `analytics_principal_arns` | **Não** consegue `sts:AssumeRole` na role Analytics — é o teste deste repo |

> "Fora do trust" (deny de **IAM/assume**, testado aqui) ≠ "Não-consumidor LF" (deny de **Lake
> Formation**, testado no Projeto 2). São duas travas diferentes; não confunda os termos entre os repos.

## Validação US-5

Após o apply, na raiz do repo:

```powershell
.\tests\simulate-principal-policy.ps1 -SorBucket "datamesh-poc-dev-sor"
```

Se o simulate falhar imediatamente após o apply, aguarde 10–20 s (eventual consistency do IAM) e repita. Sem SLO.

O **Fora do trust** (ARN fora de `analytics_principal_arns`) não deve conseguir `sts:AssumeRole` na role Analytics.

## Ordem com o Projeto 2

Esta identidade pode ser aplicada **antes** dos buckets existirem. Nomes devem coincidir — ver `aidlc-docs/construction/shared-infrastructure.md`.

```
Montar:    Projeto 1 (este) apply  →  Projeto 2 apply
Desmontar: Projeto 2 destroy        →  Projeto 1 (este) destroy
```

State e `*.tfvars` reais não entram no git (`example.tfvars` é a exceção).
