# Instrucoes de Testes de Desempenho

## Proposito

Os NFR desta unidade **nao definem SLO** de latencia, throughput ou usuarios concorrentes. IAM e servico gerenciado da AWS; `apply` em tempo de engenheiro e aceitavel.

## Requisitos de Desempenho

- **Tempo de Resposta / Throughput / Usuarios concorrentes / Taxa de erro**: N/A

## Executar Testes de Desempenho

Nao executar JMeter/k6 para esta POC.

Se no futuro houver alvo: medir duracao de `terraform apply` em conta vazia de identidade (informal, sem meta).

## Status

**N/A** — alinhado a `nfr-requirements.md`.
