# NFR Design Patterns — u1-identity-iam

## Resiliência

- **Retry nativo:** Terraform/AWS provider. Sem wrapper de backoff em `tests/`.
- **Recuperação:** P1 reexecuta `apply` se o comando falhar (rede/throttling).
- **Teardown:** `destroy` limpa só identidades desta unidade (US-6). Sem `prevent_destroy`.
- Sem circuit breaker, fila de retry ou multi-AZ.

## Escalabilidade

- Sem factory, pool ou policy compartilhada entre Glue e Analytics.
- Uma policy (ou conjunto) **por identidade**, allow só no perímetro.
- Lista de principais dimensionada para dezenas, não para growth.

## Desempenho / consistência

- Sem cache, CDN ou alvo de latência.
- **Eventual consistency IAM:** README e `SimulateScript` documentam espera curta **somente se** `simulate-principal-policy` falhar de forma transitória após o apply. Sem SLO.

## Segurança

- **Deny by default:** só statements Allow no perímetro (`sor`/`sot`/`spec`, resultados Athena, catálogo/partitions, workgroup, GetDataAccess/logs justificados).
- Sem AWS managed `*FullAccess`.
- Sem Deny explícito extra de `s3:*` em `Resource *`.
- Trust Glue com restrição de conta origem; Analytics só com `PrincipalRef` validados.
- Segredos fora do git (ver componentes lógicos).

## Extensões

Security Baseline, Resiliency Baseline e PBT: **N/A**.
