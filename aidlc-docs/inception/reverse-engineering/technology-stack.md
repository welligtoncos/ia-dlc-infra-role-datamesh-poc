# Stack Tecnológica

## Linguagens de Programação

- HCL (Terraform) - Terraform >= 1.7.5 - IaC IAM
- PowerShell - Windows - script de simulação IAM
- POSIX shell - Unix - script de simulação IAM equivalente

## Frameworks

- HashiCorp Terraform - >= 1.7.5 - provisionamento
- AWS Provider - ~> 5.0 (lock 5.100.0) - recursos IAM

## Infraestrutura

- AWS IAM - roles, policies, trust, simulate-principal-policy
- AWS STS - assume role em runtime (Glue service / principals Analytics)
- Referências (não criadas): S3, Glue Catalog, Athena, CloudWatch Logs, Lake Formation

## Ferramentas de Build

- Terraform CLI - `init`, `fmt`, `validate`, `plan`, `apply`, `destroy`
- Sem pipeline CI/CD no repositório

## Ferramentas de Teste

- AWS CLI - `iam simulate-principal-policy`
- Terraform output - obtenção dos ARNs após apply
- Sem framework de unit test (terratest, terraform-compliance, checkov no repo)
