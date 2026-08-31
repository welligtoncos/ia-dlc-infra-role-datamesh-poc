# Unit of Work — InfraRoles Mini + incremento multi-env

U1 permanece **completa** (POC v1). Este incremento acrescenta U2 e U3. Construction do incremento: **U2 em série, depois U3**. Functional Design SKIP nas duas.

---

## u1-identity-iam (entregue — não reabrir)

| Campo | Valor |
|-------|--------|
| ID | `u1-identity-iam` |
| Tipo | Serviço `IdentityPlatform` |
| Status | Completa (Construction POC v1) |
| Apply | Um root na **raiz** do workspace; state era local (U3 troca para remoto) |
| Histórias | US-1 a US-6 |
| Código | `glue.tf`, `analytics.tf`, `variables.tf`, `outputs.tf`, … na raiz — **não mover** |

Não há novo loop de Construction na U1 para policies. U3 apenas **emenda** backend + validation de `environment`.

---

## u2-bootstrap

| Campo | Valor |
|-------|--------|
| ID | `u2-bootstrap` |
| Tipo | Serviço `BootstrapService` |
| Contexto | Preparação da conta (backend + OIDC) |
| Dono | P1 |
| Apply | `bootstrap/` — state **local**, uma vez por conta (admin) |
| RFs | RF-ME3 (principal); habilita RF-ME2/RF-ME4 |
| DoD | `terraform apply` em `bootstrap/` cria S3, DynamoDB, OIDC provider, deploy role; README do bootstrap |

### Responsabilidades

- Root Terraform em `bootstrap/`
- Não criar Glue/Analytics; não workflows
- Outputs (ARN da deploy role, nomes de bucket/tabela) para o operador colar no GitHub / `backend.hcl` — **sem** `terraform_remote_state` na U3

### Módulos lógicos

| Módulo | Papel |
|--------|--------|
| BootstrapStack | S3, DynamoDB, OIDC, deploy role |

### Organização de código

```
<workspace-root>/
  bootstrap/
    versions.tf
    provider.tf
    variables.tf
    main.tf          # (ou arquivos por recurso)
    outputs.tf
  glue.tf            # U1 — nao pertence a U2
  aidlc-docs/
```

### Construction (esta unidade primeiro)

NFR Requirements → NFR Design → Infrastructure Design → Code Generation → (Build and Test da U2 pode ser local validate; o BT global do incremento pode esperar U3)

---

## u3-identity-ci

| Campo | Valor |
|-------|--------|
| ID | `u3-identity-ci` |
| Tipo | Serviço `DeployService` |
| Contexto | Publicação da identidade (roles + pipeline) |
| Dono | P1 |
| Apply | Root U1 na raiz com backend S3; CI `run(env)` |
| RFs | RF-ME1, RF-ME2, RF-ME4, RF-ME5, RF-ME6, RF-ME7 |
| DoD | Três workflows; `env/*.tfvars` + `env/*.backend.hcl`; identity `init` remoto; simulate.sh no CI; README (hom, var-file, .ps1 vs .sh) |

### Responsabilidades

- EnvConfig + backend parcial/`backend.hcl` no root U1
- Três GitHub workflows; sem destroy no CI
- Não reescrever policies Glue/Analytics salvo validation `environment` ∈ {dev,hom,prod}
- Depende **operacionalmente** da U2 aplicada na conta

### Módulos lógicos

| Módulo | Papel |
|--------|--------|
| EnvConfig | tfvars + backend.hcl |
| CiPipelines | três YAML |
| IdentityPlatform | root U1 + backend remoto |

### Organização de código

```
<workspace-root>/
  versions.tf              # U1 + backend s3 parcial
  glue.tf / analytics.tf   # U1 inalterados em proposito
  env/
    dev.tfvars
    hom.tfvars
    prod.tfvars
    dev.backend.hcl
    hom.backend.hcl
    prod.backend.hcl
  .github/workflows/
    deploy-dev.yml
    deploy-hom.yml
    deploy-prod.yml
  tests/simulate-principal-policy.sh
  bootstrap/               # U2 — nao gerar de novo na U3
```

### Construction (depois da U2)

Mesma sequência NFR → NFR Design → Infrastructure Design → Code Generation.

---

## Conformidade com extensões

| Extensão | Status |
|----------|--------|
| Security Baseline | N/A |
| Resiliency Baseline | N/A |
| Property-Based Testing | N/A |
