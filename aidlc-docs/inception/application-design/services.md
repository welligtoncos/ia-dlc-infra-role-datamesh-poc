# Services — Incremento multi-env

Dois serviços (Q3-A). Nenhum `apply` único cobre os dois. IdentityPlatform da POC v1 permanece o rótulo do **segundo** apply (identidade).

---

## BootstrapService

| Campo | Valor |
|-------|--------|
| Tipo | Serviço one-shot |
| Implantação | `BootstrapStack.apply_once` na workstation, **por conta** |
| Orquestração | Só este root; state local |

### Responsabilidades

- Materializar state backend + OIDC + deploy role **antes** de qualquer pipeline
- Não aplicar Glue/Analytics
- Não rodar no GitHub Actions

### Quem opera

Engenheiro com admin na conta alvo (três vezes: dev, hom, prod).

---

## DeployService

| Campo | Valor |
|-------|--------|
| Tipo | Serviço contínuo |
| Implantação | `CiPipelines.run(env)` (GitHub Actions) **ou** apply local do IdentityPlatform com EnvConfig |
| Orquestração | CI assume a deploy role (OIDC), `init` com backend.hcl, plan/apply do identity root, chama simulate.sh |

### Responsabilidades

- Aplicar só o root de identidade na conta do `env`
- Isolar os três ambientes (um workflow não assume a role dos outros)
- Hom/prod: esperar aprovação do GitHub Environment

### Quem opera

- Push/`workflow_dispatch` + aprovador em hom/prod
- Engenheiro local: mesmo IdentityPlatform, sem `CiPipelines.run`

### Serviços que não existem

- `MultiEnvIdentity` único (Q3-B)
- Um serviço por ambiente (Q3-C) — é o mesmo DeployService com `env` diferente
- Serviço de verificação — Build and Test
