# NFR Requirements — u3-identity-ci

CI e configuração de apply da identidade (EnvConfig + CiPipelines). Sem UI. Extensões Security/Resiliency/PBT **N/A**. Design funcional SKIP; base RF-ME1/2/4/5/6/7. Glue/Analytics inalterados em propósito.

## Escalabilidade

- Três pipelines independentes (um env cada). Sem um único push aplicando os três.
- `concurrency` **por workflow** (grupo `identity-{env}`): no máximo um run por ambiente. Fila; **`cancel-in-progress: false`**. O segundo push espera; não cancela apply em andamento (evita lock DynamoDB órfão).

## Desempenho

- Sem SLO de duração “feliz”. Job com **`timeout-minutes: 20`** (IAM-only costuma ser poucos minutos; 20 min = falha cedo se o runner congelar).
- Timeout aplica-se a **cada** job (plan e apply, quando separados).

## Disponibilidade

- Runners **GitHub-hosted `ubuntu-latest`**. Sem self-hosted, sem HA da pipeline.
- Indisponibilidade do GitHub = não aplica (aceitável nesta POC).

## Segurança operacional

- OIDC já fechado (U2 role + `sub` environment). Sem access keys.
- `permissions`: `contents: read`, `id-token: write`. Checkout com **`persist-credentials: false`**.
- **Nenhum** `on.pull_request` que execute apply (ou plan+apply na conta).
- ARN da deploy role = variável do **GitHub Environment** (não secret de access key).
- **dev** sem aprovação humana (RF Q6-B). Hom/prod: Environment no job de **apply** apenas.

## Confiabilidade

- **Hom/prod — dois jobs:** `plan` (sem Environment / sem aprovação) gera `tfplan` e publica artifact; `apply` (Environment `hom`/`prod`) baixa o artifact e `terraform apply tfplan`. O aprovador lê o plan no log do job `plan` e só então libera o apply.
- **Dev — um job:** sem aprovação; ainda `plan -out=tfplan` + `apply tfplan`.
- `tests/simulate-principal-policy.sh` após apply; **exit ≠ 0 falha o job**.
- Sem `terraform apply -auto-approve` sem arquivo de plan (o apply deve ser o plan gravado).

## Manutenibilidade

- Workflow **reutilizável** (lógica única) + três callers finos (`deploy-dev.yml` / `deploy-hom.yml` / `deploy-prod.yml`) com `on:`, environment e caminhos `env/{env}.tfvars` + `env/{env}.backend.hcl`.
- README (RNF-ME5): branch `hom`, bootstrap → vars GitHub, local sem `-var-file`, CI com `-var-file`, `.ps1` vs `.sh`.
- `env/*.tfvars` e `env/*.backend.hcl` commitados (placeholders ok). `.gitignore` permite `env/*.tfvars`.

## Usabilidade

- N/A para UI. Operador: GitHub Environments + README.

## Conformidade com extensões

| Extensão | Status |
|----------|--------|
| Security Baseline | N/A |
| Resiliency Baseline | N/A |
| Property-Based Testing | N/A |
