# Component Methods — Incremento multi-env

Assinaturas de **interface** (Q2-C). Sem YAML steps nem `aws_*` detalhados.

---

## BootstrapStack

| Operação | Entrada | Saída | Propósito |
|----------|---------|-------|-----------|
| `apply_once` | Credencial admin na conta alvo; vars de naming/repo GitHub | State local + backend + OIDC + deploy role | Uma vez por conta; **não** no CI |
| `destroy_local` | State local do bootstrap | Remove backend/OIDC/role desta pasta | Manual; arriscado se o identity já usa o S3 |

---

## IdentityPlatform (root de identidade — POC v1 + backend)

| Operação | Entrada | Saída | Propósito |
|----------|---------|-------|-----------|
| `plan` | EnvConfig (tfvars + backend.hcl) | Plano | Preview |
| `apply` | Idem; lista `analytics_principal_arns` não vazia | State **remoto** na conta + roles | Provisionar Glue + Analytics + contrato |
| `output` | State aplicado | Três ARNs (Acesso = null) | Projeto 2 / engenheiro |
| `destroy` | State remoto | Remove só recursos deste root | Manual/local; **não** é método de CiPipelines |

**Local (Windows):** copiar `env/{env}.tfvars` → `terraform.tfvars`; `init -backend-config=env/{env}.backend.hcl`. Sem `-var-file=` no PowerShell.

**CI:** `-var-file=env/{env}.tfvars` e `-backend-config=env/{env}.backend.hcl`.

GlueIdentity / AnalyticsIdentity / OutputContract: mesmas interfaces `configure` / `role_arn` / `bind` da POC v1.

---

## EnvConfig

| Interface | Tipo | Descrição |
|-----------|------|-----------|
| `tfvars(env)` | arquivo | `environment`, buckets, workgroup, `analytics_principal_arns`, placeholders de account |
| `backend_hcl(env)` | arquivo | bucket, dynamodb_table, key, region (placeholders) |

Não tem `apply`. Só é lido.

---

## CiPipelines

| Operação | Entrada | Saída | Propósito |
|----------|---------|-------|-----------|
| `run(env)` | Branch/dispatch; GitHub Environment `env`; vars (account id, role OIDC ARN); EnvConfig | Plan + apply (dev auto; hom/prod após aprovação) + log do simulate.sh | Deploy isolado |

**Não** expõe `destroy`.

Invoca `tests/simulate-principal-policy.sh` após apply; não é dono da verificação (Q6-A).

---

## Fora deste documento

- Trust OIDC (`sub`, environment) → Infrastructure Design / NFR Design
- Matriz IAM Glue/Analytics → Functional Design (POC v1; estágio SKIP neste incremento)
