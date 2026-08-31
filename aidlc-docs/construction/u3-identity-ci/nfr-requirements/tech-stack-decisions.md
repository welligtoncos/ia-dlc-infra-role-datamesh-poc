# Tech Stack Decisions — u3-identity-ci

| Decisão | Escolha | Justificativa |
|---------|---------|----------------|
| CI | GitHub Actions | RF-ME4 |
| Runners | `ubuntu-latest` (hosted) | Q3-A; RNF-ME3 |
| Terraform no CI | `hashicorp/setup-terraform`, `terraform_version` **1.9.8**, `terraform_wrapper: false` | Q5-B; `required_version` nos `.tf` permanece `>= 1.7.5` |
| Provider AWS | `hashicorp/aws ~> 5.0` + lockfile na **raiz** (U1) | RNF-ME1; U3 não troca o provider |
| Auth CI | `aws-actions/configure-aws-credentials` OIDC; role ARN via Environment var | Q4-A; RNF-ME2 |
| Backend identidade | S3 + DynamoDB; `terraform init -backend-config=env/{env}.backend.hcl` | RF-ME2; U2 cria os recursos |
| Var-file CI | `-var-file=env/{env}.tfvars` | RF-ME5 |
| Plan/apply | `plan -out=tfplan` + artifact; `apply tfplan` | Q6-B |
| Workflows | Reusable + três callers | Q7-B |
| Simulate CI | `tests/simulate-principal-policy.sh` (AWS CLI no runner) | RNF-ME3 |
| Observabilidade | Logs do Actions; sem CloudWatch desta unidade | POC |
| Local | `terraform.tfvars` copiado; sem `-var-file` no PowerShell | RF-ME5 |

## Fora de stack

- Self-hosted runners
- Access keys no GitHub
- `pull_request` apply
- Três YAML completos duplicados
- `terraform apply -auto-approve` sem `tfplan`
- `cancel-in-progress` no concurrency
- Terraform 1.7.5 pinado no CI (mínimo, não o pin escolhido)
- CDK, Terraform Cloud, CodePipeline
