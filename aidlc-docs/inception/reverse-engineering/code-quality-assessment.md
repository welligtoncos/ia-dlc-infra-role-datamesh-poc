# Avaliação de Qualidade de Código

## Cobertura de Testes

- **Geral**: Razoável para POC IAM; nenhuma automação em CI
- **Testes Unitários**: Nenhuma (sem terratest / python unittest)
- **Testes de Integração**: Scripts manuais pós-apply (`tests/simulate-principal-policy.ps1` / `.sh`)
- **Validação estática**: `terraform fmt` / `validate` documentados; lockfile presente

## Indicadores de Qualidade de Código

- **Linting**: Terraform fmt (não enforced em hook/CI)
- **Estilo de Código**: Consistente (um arquivo por role, locals centralizados, SIDs nas statements)
- **Documentação**: Boa (README, aidlc-docs de construction, example.tfvars)

## Débito Técnico

- State local: sem locking remoto; inseguro para mais de um operador ou para pipeline
- Sem backend por ambiente: repetir apply com `environment=hom` na mesma pasta colide com o state de `dev`
- Check same-account impede principals cross-account (correto para POC; bloqueia modelo org com consumidores em outra conta)
- Contrato Projeto 2 assume uma conta; 3 contas exigem o Projeto 2 também por ambiente
- Sem CI: apply depende da workstation e da default credential chain
- `environment` não tem `validation` (aceita qualquer string; não restringe a `dev`/`hom`/`prod`)
- PowerShell e `-var-file`: documentado, mas pipeline Linux não terá o mesmo problema

## Padrões e Antipadrões

- **Bons Padrões**: menor privilégio; SourceAccount no trust Glue; check Terraform para principals; outputs estáveis; tfvars reais fora do git
- **Antipadrões**: nenhum grave para POC de uma conta; o modelo “um root + state local” é inadequado para três contas sem mudança de backend e de orquestração
