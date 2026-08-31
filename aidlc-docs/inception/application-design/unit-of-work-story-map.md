# Unit of Work Story Map — Incremento multi-env

Histórias de usuário deste incremento: **N/A** (estágio pulado). Mapa = US da U1 + RF-ME nas U2/U3. Nenhuma RF-ME órfã.

## Mapa unidade → histórias / RFs

| Unidade | Histórias / RFs | Notas |
|---------|-----------------|--------|
| `u1-identity-iam` | US-1 a US-6 | Entregue; não reabrir |
| `u2-bootstrap` | RF-ME3 | Habilita RF-ME2 e RF-ME4 |
| `u3-identity-ci` | RF-ME1, RF-ME2, RF-ME4, RF-ME5, RF-ME6, RF-ME7 | Também RF-ME3 como premissa operacional |

## Mapa história / RF → unidade

| ID | Unidade | Módulo / operação | Dono |
|----|---------|-------------------|------|
| US-1 | u1 | GlueIdentity | P1 |
| US-2 | u1 | AnalyticsIdentity | P2 |
| US-3 | u1 | OutputContract | P1 |
| US-4 | u1 | variáveis do root | P1 |
| US-5 | u1 (script) + u3 (CI invoca .sh) | Build and Test | P1 |
| US-6 | u1 destroy; u3 destroy **não** no CI | IdentityPlatform.destroy local | P1 |
| RF-ME1 | u3 | validation environment | P1 |
| RF-ME2 | u3 (backend.hcl) + u2 (cria bucket/tabela) | EnvConfig + BootstrapStack | P1 |
| RF-ME3 | u2 | BootstrapStack.apply_once | P1 |
| RF-ME4 | u3 | CiPipelines + branch hom | P1 |
| RF-ME5 | u3 | run(env) + var-file CI vs local | P1 |
| RF-ME6 | u3 | EnvConfig tfvars | P1 |
| RF-ME7 | u3 | isolamento OIDC/environments | P1 |

## Cobertura RF-ME

| ID | Atribuída | Unidade primária |
|----|-----------|------------------|
| RF-ME1 | sim | u3-identity-ci |
| RF-ME2 | sim | u3 (uso) / u2 (cria backend) |
| RF-ME3 | sim | u2-bootstrap |
| RF-ME4 | sim | u3-identity-ci |
| RF-ME5 | sim | u3-identity-ci |
| RF-ME6 | sim | u3-identity-ci |
| RF-ME7 | sim | u3-identity-ci |
