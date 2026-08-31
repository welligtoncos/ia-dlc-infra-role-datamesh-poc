# Logical Components — u2-bootstrap

Componentes lógicos **NFR** (não são o bucket, a tabela, o OIDC provider nem a deploy role). Sem fila, cache ou circuit breaker.

| Componente | Responsabilidade |
|------------|------------------|
| BootstrapGitIgnore | Excluir state local em `bootstrap/` (`.terraform/`, `*.tfstate*`); `*.tfvars` com exceção de `example.tfvars` |
| BootstrapExampleTfvars | `bootstrap/example.tfvars`: repo GitHub, environment, região, prefixo, placeholders |
| BootstrapLockfile | `bootstrap/.terraform.lock.hcl` versionado |
| BootstrapReadme | Apply uma vez por conta; outputs a copiar; checklist pós-apply; aviso: `prevent_destroy`; ordem destroy (U3 antes, depois editar lifecycle) |
| OidcThumbprint | Constante/local do thumbprint GitHub OIDC (valor estático AWS) |

## Integração

```
P1 admin -> terraform apply em bootstrap/ (retry nativo)
         -> S3 + DDB (prevent_destroy, sem force_destroy)
         -> OIDC + deploy role (aud + sub environment)
GitIgnore protege state local do bootstrap
ExampleTfvars e Lockfile entram no git
Readme: checklist + nao destruir backend com U3 viva
```

## Fora deste desenho

- Makefile
- Workflows GitHub (U3)
- CloudWatch alarms
- `hashicorp/tls`
