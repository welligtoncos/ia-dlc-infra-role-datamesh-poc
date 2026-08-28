# PRD — Projeto 1: Camada de Identidade (InfraRoles Mini)

| Campo | Valor |
|-------|-------|
| Produto | Plataforma de IAM Roles/Policies para Data Mesh pessoal |
| Versão | 1.0 (POC) |
| Autor | — |
| Status | Rascunho |
| Ordem de entrega | **1 de 2** (dependência do Projeto 2) |

---

## 1. Resumo Executivo
Provisionar, via Terraform, a camada de identidade e acesso (IAM Roles e Policies) que dá
permissão de menor privilégio aos serviços de uma arquitetura Data Mesh pessoal em uma única
conta AWS. Este projeto entrega os ARNs consumidos pela plataforma de dados (Projeto 2).

## 2. Contexto e Problema
Uma arquitetura Data Mesh exige governança de acesso: cada serviço (Glue, Athena) precisa de
uma identidade com permissões específicas, e cada consumidor de dados precisa de acesso
controlado. Sem essa camada, não há como o Lake Formation aplicar permissões nem como os
jobs de ETL rodarem com segurança. Hoje, para uma POC pessoal, não existe esse conjunto de
roles — e o módulo corporativo original não está disponível fora do ambiente Itaú.

## 3. Objetivos e Metas
- **O1.** Criar roles versionadas e reprodutíveis via IaC.
- **O2.** Aplicar menor privilégio, escopando permissões aos recursos da POC.
- **O3.** Expor ARNs como contrato de integração para o Projeto 2.
- **O4.** Ser 100% destruível/recriável (`apply`/`destroy` limpos).

**Não-objetivos:** multi-conta, roles de ECS/EventBridge/mainframe, ambientes hom/prod.

## 4. Escopo

**Dentro do escopo:**
- Role de Glue (ETL/catálogo)
- Role de Analytics (consumo governado, leitura)
- Role de Acesso (opcional, automação)
- Permission policies + trust policies por serviço
- Outputs com os ARNs

**Fora do escopo:**
- Módulo corporativo `itau-ey4-modulo-iamsr`
- Federação SSO / IdP corporativo
- Rotação de credenciais e políticas de senha

## 5. Personas / Stakeholders
- **Engenheiro de dados (você):** cria e mantém a infra.
- **Glue Job (sistema):** assume role para ETL.
- **Analista/BI (consumidor):** assume role de leitura para Athena.

## 6. Requisitos Funcionais
- **RF1.** O sistema deve criar uma role de Glue com trust para `glue.amazonaws.com`.
- **RF2.** A role de Glue deve permitir R/W nos buckets das camadas, operações de catálogo
  Glue, `lakeformation:GetDataAccess` e logs.
- **RF3.** O sistema deve criar uma role de Analytics com trust para o principal do usuário.
- **RF4.** A role de Analytics deve ter apenas leitura (Glue read-only, LF GetDataAccess,
  Athena query, S3 read + write no bucket de resultados).
- **RF5.** O sistema deve expor `glue_role_arn`, `analytics_role_arn`, `access_role_arn`
  via `terraform output`.

## 7. Requisitos Não-Funcionais
- **RNF1.** Terraform >= 1.7.5, AWS Provider ~> 5.0.
- **RNF2.** Nenhum recurso deprecated.
- **RNF3.** Nenhuma policy com `Resource: "*"` sem justificativa documentada.
- **RNF4.** Segredos/ARNs reais não versionados em repositório público.
- **RNF5.** Nomes parametrizados por `project_prefix` e `environment`.

## 8. Premissas e Restrições
- Conta AWS pessoal com acesso administrativo.
- Ambiente único (`dev`), região `sa-east-1` (ajustável).
- Buckets referenciados devem ter os mesmos nomes usados no Projeto 2.

## 9. Dependências
- **Nenhuma dependência de entrada.**
- **É dependência de saída do Projeto 2** (que consome os ARNs).

## 10. Roadmap / Marcos
| Marco | Entrega |
|-------|---------|
| M1 | Bootstrap Terraform (versions/variables/provider) |
| M2 | Role + policy + trust de Glue |
| M3 | Role + policy + trust de Analytics |
| M4 | Outputs dos ARNs |
| M5 | `apply` validado + ARNs capturados |

## 11. Critérios de Aceite / Métricas de Sucesso
- ✅ `terraform apply` conclui sem erro.
- ✅ `terraform output` retorna os 3 ARNs.
- ✅ `aws iam simulate-principal-policy` confirma acesso permitido nos buckets da POC e
  negado fora deles.
- ✅ `terraform destroy` remove todos os recursos.

## 12. Riscos
| Risco | Impacto | Mitigação |
|-------|---------|-----------|
| Permissões amplas demais | Segurança | Revisão de policy no `plan`; menor privilégio |
| Nome de bucket divergente do Projeto 2 | Integração quebra | Centralizar nomes em variáveis compartilhadas |
| Trust incorreta impede o serviço de assumir | ETL não roda | Testar com `simulate-principal-policy` |

## 13. Questões em Aberto
1. A role de Analytics será assumida por usuário IAM ou por SSO/role federada?
2. A role de Acesso entra na POC ou fica de fora?
3. Região definitiva e prefixo de nomes?
