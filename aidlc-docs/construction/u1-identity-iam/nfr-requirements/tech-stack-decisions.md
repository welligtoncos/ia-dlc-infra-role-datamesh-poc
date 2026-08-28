# Tech Stack Decisions — u1-identity-iam

| Decisão | Escolha | Justificativa |
|---------|---------|----------------|
| Linguagem / IaC | Terraform HCL | PRD / RNF1 |
| Terraform | `required_version >= 1.7.5` | RNF1; não pin 1.7.5 exato |
| Provider AWS | `hashicorp/aws ~> 5.0` | RNF1; sem `>= 5.0` largo |
| Lockfile | Commitar `.terraform.lock.hcl` | Reproduzibilidade do provider |
| Região | Variável `aws_region` default `sa-east-1` | Requirements |
| Backend | Local | POC; cópia manual opcional |
| Secrets no git | Não; `example.tfvars` + gitignore `*.tfvars` | RNF4 |
| Testes | `terraform validate` + script `tests/` de simulate | US-5; sem CI |
| CI | Nenhum nesta POC | Q7-B |
| Observabilidade | CLI + README | Sem CloudWatch alarms |
| Runtime app | Nenhum | Só IAM |

## Fora de stack

- Módulo corporativo `itau-ey4-modulo-iamsr`
- CDK, Pulumi, CloudFormation
- Backend remoto, encryption do state
- GitHub Actions
