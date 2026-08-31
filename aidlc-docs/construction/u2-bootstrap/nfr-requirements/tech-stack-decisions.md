# Tech Stack Decisions — u2-bootstrap

| Decisão | Escolha | Justificativa |
|---------|---------|----------------|
| IaC | Terraform HCL | Igual U1 |
| Terraform | `>= 1.7.5` | RNF-ME1 / U1 |
| Provider | só `hashicorp/aws ~> 5.0` + lockfile em `bootstrap/` | Q5-A; sem `tls` |
| OIDC GitHub | `aws_iam_openid_connect_provider` + `thumbprint_list` estático documentado pela AWS | Sem data source TLS |
| Região | Variável, default `sa-east-1` | POC |
| Backend deste root | Local | Ovo-e-galinha; gitignore |
| Backend criado para U3 | S3 + DynamoDB (SSE-S3, versioning, BPA, PITR) | Q3-B |
| Deploy auth | OIDC; 1 role/conta; `sub` repo + environment | Q4-B refinado |
| Secrets no git | `bootstrap/example.tfvars`; reais gitignored | Q7-B |
| Observabilidade | CLI + README checklist | Q6-A |
| CI nesta unidade | Nenhum | Apply local admin |

## Fora de stack

- `hashicorp/tls`
- KMS CMK
- Três deploy roles na mesma conta
- CRR / DynamoDB global tables
- Alarmes CloudWatch
