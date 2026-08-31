# Operations — Placeholder

A fase de Operations do AI-DLC **não** tem workflow de implantação/monitoramento nesta versão das regras. O incremento multi-env **termina** aqui.

## O que vale neste incremento

A implantação está na Construction, não neste estágio:

- `README.md` (raiz): bootstrap, migrate-state, apply local, pipelines GitHub Actions, destroy
- `identity/`: root Terraform das roles Glue + Analytics
- `bootstrap/README.md`: apply uma vez por conta
- `.github/workflows/`: `deploy-dev` / `deploy-hom` / `deploy-prod` + reusable
- `aidlc-docs/construction/build-and-test/`: validate, integração U2→U3, simulate, E2E
- `aidlc-docs/construction/shared-infrastructure.md`: contrato de contas, backend, Environments

Sem CloudWatch dedicado, runbook de incidente ou checklist de produção no estágio Operations.

## Escopo futuro (não nesta versão do AI-DLC)

- Planejamento e execução de implantação como estágio próprio
- Observabilidade e alarmes
- Resposta a incidentes
- Manutenção e suporte
- Checklist de prontidão para produção
