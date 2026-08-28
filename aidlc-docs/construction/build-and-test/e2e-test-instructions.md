# Instrucoes de Testes End-to-End

Fluxo do engenheiro (P1). Sem UI.

## Cenario feliz

1. Copiar `example.tfvars` → `terraform.tfvars` e preencher valores reais
2. `terraform init && terraform validate && terraform plan -var-file=terraform.tfvars`
3. `terraform apply -var-file=terraform.tfvars`
4. Conferir os tres outputs (Acesso null)
5. Rodar `tests/simulate-principal-policy.*`
6. (Opcional) `sts assume-role` com P2 listado vs Nao-consumidor
7. `terraform destroy -var-file=terraform.tfvars`
8. Confirmar que as duas roles sumiram; buckets do Projeto 2 (se existirem) permanecem

## Nao executado automaticamente

Apply/destroy exigem conta AWS e `tfvars` reais. Este ambiente so validou `init` + `validate`.
