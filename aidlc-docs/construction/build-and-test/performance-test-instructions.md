# Instruções de Testes de Desempenho

## Propósito

NFR desta POC: **sem SLO**. Job CI com `timeout-minutes: 20`. IAM-only.

## Requisitos de Desempenho

- **Tempo de Resposta**: N/A
- **Throughput**: N/A
- **Usuários Concorrentes**: N/A (concurrency Terraform = um apply por env)
- **Taxa de Erro**: N/A

Não executar JMeter/k6. Se um job passar de 20 minutos, o Actions cancela (travamento, não carga).

## Otimização

Não aplicável. Sem `actions/cache` de providers (NFR Design).
