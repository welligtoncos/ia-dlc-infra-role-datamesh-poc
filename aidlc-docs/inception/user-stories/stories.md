# Histórias de Usuário — InfraRoles Mini

**Decomposição:** híbrida (capability + persona). **Granularidade:** 6 histórias. **Idioma:** português.

Critérios: Gherkin para assume-role / consumo; checklist para provisionamento Terraform. Sem detalhe de resources HCL.

INVEST: Independent (podem ser negociadas em ordem), Negotiable, Valuable, Estimable, Small, Testable.

---

## US-1 — Execution role para Glue

**Persona-dona:** P1 Engenheiro de dados (cria e mantém a role)  
**Ator de aceite (não-persona):** Glue Job / Crawler — aparece só no Gherkin; **não** é persona desta história  
**Valor:** Jobs e crawlers da POC têm identidade para ler/escrever nas camadas e registrar logs, sem poder administrar o catálogo.  
**Rastreio:** RF1, RF2, RNF3, RNF5

**História**  
Como engenheiro de dados, quero provisionar uma execution role para Glue, para que um Glue Job da POC (ator de aceite, não persona) opere nas camadas `sor`, `sot` e `spec` com menor privilégio.

### Aceite — provisionamento (checklist)

- [ ] Após `terraform apply`, existe uma role cujo nome deriva de `project_prefix` + `environment`
- [ ] Apenas o serviço Glue pode assumir essa role
- [ ] A role tem R/W nos buckets `sor`, `sot` e `spec` (objetos e prefixos)
- [ ] A role tem as operações de catálogo necessárias à **execução** de job/crawler (sem criar/atualizar jobs, crawlers ou databases)
- [ ] A role tem `lakeformation:GetDataAccess` e escrita de logs do Glue
- [ ] `Resource: "*"` só aparece com justificativa documentada (ex.: `GetDataAccess`)

### Aceite — uso (Gherkin)

O sujeito dos cenários abaixo é o **Glue Job** (ator de aceite). A persona-dona continua sendo o engenheiro; o Job não substitui a P1.

```
Dado um Glue Job na conta da POC
Quando o job assume a execution role
Então o assume é permitido
E o job pode ler e escrever nos buckets sor, sot e spec
E o job pode obter data access no Lake Formation
E o job pode escrever logs

Dado a mesma execution role
Quando se tenta acesso de escrita ou leitura a um bucket fora da POC
Então a ação é negada
```

---

## US-2 — Role de Analytics (leitura governada)

**Persona-dona:** P2 Analista / BI (consumo via Athena)  
**Ator de aceite (não-persona):** nenhum nesta história; o Não-consumidor (ARN fora de `analytics_principal_arns`) é o controle negativo da **US-5**  
**Valor:** Consultar dados via Athena sem alterar as camadas da malha.  
**Rastreio:** RF3, RF4, RNF3, RNF5

**História**  
Como analista/BI, quero uma role de leitura governada, para consultar `sor`, `sot` e `spec` via Athena e gravar resultados só no bucket de query.

### Aceite — provisionamento (checklist)

- [ ] Após `terraform apply`, existe uma role de Analytics com nome derivado de `project_prefix` + `environment`
- [ ] Somente os ARNs em `analytics_principal_arns` (users e/ou roles da mesma conta) podem assumir a role
- [ ] A role tem leitura no catálogo Glue (Get/List; sem Create/Update/Delete)
- [ ] A role tem `lakeformation:GetDataAccess` e permissões para executar e acompanhar queries Athena
- [ ] A role tem leitura em `sor`, `sot` e `spec` e R/W **somente** no bucket de resultados do Athena

### Aceite — uso (Gherkin)

```
Dado que o ARN do analista está em analytics_principal_arns
Quando o analista assume a role de Analytics
Então o assume é permitido
E o analista pode ler sor, sot e spec
E o analista pode executar e acompanhar queries Athena
E o analista pode ler e escrever no bucket de resultados do Athena
E o analista não pode criar nem alterar objetos nas camadas sor, sot e spec

Dado um ARN que não está em analytics_principal_arns
Quando esse principal tenta assumir a role de Analytics
Então o assume é negado
# Nota: o sujeito deste cenário é o ator Não-consumidor, detalhado na US-5; não é a P2.

Dado a role de Analytics
Quando se tenta leitura ou escrita em um bucket fora da POC (exceto o de resultados Athena, se aplicável)
Então a ação é negada
```

---

## US-3 — Contrato de outputs para o Projeto 2

**Persona-dona:** P1 Engenheiro de dados  
**Ator de aceite (não-persona):** Projeto 2 (consome os outputs)  
**Valor:** O Projeto 2 consome ARNs estáveis sem acoplar nomes internos.  
**Rastreio:** RF5, O3

**História**  
Como engenheiro de dados, quero outputs Terraform com os ARNs da camada de identidade, para o Projeto 2 referenciar Glue e Analytics e tratar Acesso como ausente nesta POC.

### Aceite — provisionamento (checklist)

- [ ] `terraform output glue_role_arn` retorna o ARN da role de Glue
- [ ] `terraform output analytics_role_arn` retorna o ARN da role de Analytics
- [ ] `terraform output access_role_arn` retorna `null` (role de Acesso fora desta iteração)
- [ ] Os três nomes de output existem no contrato (nada omitido silenciosamente)

---

## US-4 — Parametrização da POC

**Persona-dona:** P1 Engenheiro de dados  
**Ator de aceite (não-persona):** —  
**Valor:** Reusar o mesmo código com prefixo, região, ambiente e buckets alinhados ao Projeto 2, sem criar esses buckets aqui.  
**Rastreio:** RF6, RNF1, RNF4, RNF5, RNF7, RNF8

**História**  
Como engenheiro de dados, quero parametrizar prefixo, ambiente, região, buckets das camadas, bucket Athena e a lista de principais de Analytics, para a identidade acompanhar o Projeto 2 sem versionar segredos.

### Aceite — provisionamento (checklist)

- [ ] Existem variáveis para `project_prefix` (default `datamesh-poc`), `environment` (default `dev`), `aws_region` (default `sa-east-1`)
- [ ] Existem variáveis para `sor_bucket`, `sot_bucket`, `spec_bucket`, `athena_results_bucket` (nomes apenas; buckets não são criados)
- [ ] `analytics_principal_arns` é lista obrigatória e o apply falha se estiver vazia
- [ ] Terraform `>= 1.7.5` e AWS Provider `~> 5.0`
- [ ] Exemplos de tfvars usam placeholders; valores reais e state local não entram no git
- [ ] Roles/policies recebem tags `Project`, `Environment`, `ManagedBy=terraform`

---

## US-5 — Validação transversal de menor privilégio

**Persona-dona:** P1 Engenheiro de dados (executa `simulate-principal-policy` e os testes de governança)  
**Controle positivo:** P2 Analista / BI (ARN **está** em `analytics_principal_arns`)  
**Ator de aceite (não-persona):** Não-consumidor — identidade IAM da mesma conta cujo ARN **não** está em `analytics_principal_arns`  
**Valor:** Prova objetiva de allow nas camadas da POC e de deny para quem não tem grant / está fora da lista.  
**Rastreio:** RF7, RNF3, O2

**História**  
Como engenheiro de dados, quero validar as policies das roles Glue e Analytics, para confirmar permissão nas camadas da POC, permissão da P2 como consumidor listado, e negação para o Não-consumidor e para buckets fora da POC.

### Aceite — provisionamento / validação (checklist)

- [ ] Após o apply, `aws iam simulate-principal-policy` pode ser executado contra a role de Glue e a de Analytics
- [ ] Simulação indica **allow** nas ações previstas sobre `sor`, `sot`, `spec` (e resultados Athena na Analytics)
- [ ] Simulação indica **deny** (ou ausência de allow) para um bucket fora da POC
- [ ] Existe uma identidade de controle negativo (Não-consumidor) **fora** de `analytics_principal_arns`
- [ ] Esta história complementa os cenários negativos de US-1 e US-2; não os substitui

### Aceite — governança (Gherkin)

```
Dado que o ARN da P2 está em analytics_principal_arns
Quando a P2 assume a role de Analytics e executa uma query Athena sobre as camadas da POC
Então o assume é permitido
E a query é permitida no perímetro da role (leitura das camadas; escrita só no bucket de resultados)

Dado o Não-consumidor (ARN ausente de analytics_principal_arns)
Quando o Não-consumidor tenta assumir a role de Analytics
Então o assume é negado

Dado o Não-consumidor
Quando tenta uma query Athena (ou GetDataAccess) sobre sor, sot ou spec como se tivesse grant
Então a ação é negada
```

---

## US-6 — Destruição limpa

**Persona-dona:** P1 Engenheiro de dados  
**Ator de aceite (não-persona):** —  
**Valor:** A POC pode ser apagada e recriada sem resíduos de identidade deste projeto.  
**Rastreio:** RNF6, O4

**História**  
Como engenheiro de dados, quero destruir toda a camada de identidade desta POC, para recriar o ambiente sem roles ou policies órfãs.

### Aceite — provisionamento (checklist)

- [ ] `terraform destroy` conclui sem erro
- [ ] As roles Glue e Analytics criadas por este projeto deixam de existir
- [ ] Nenhum recurso órfão criado por este projeto permanece na conta
- [ ] Buckets referenciados (Projeto 2) **não** são destruídos por este destroy

---

## Cobertura requisitos → histórias

| Requisito | História |
|-----------|----------|
| RF1, RF2 | US-1 |
| RF3, RF4 | US-2 |
| RF5 | US-3 |
| RF6 | US-4 |
| RF7 | US-5 (e negativos em US-1, US-2) |
| RNF1, RNF4, RNF5, RNF7, RNF8 | US-4 |
| RNF3 | US-1, US-2, US-5 |
| RNF6, O4 | US-6 |
| O3 | US-3 |

## Conformidade INVEST (resumo)

| ID | I | N | V | E | S | T |
|----|---|---|---|---|---|---|
| US-1 | x | x | x | x | x | x |
| US-2 | x | x | x | x | x | x |
| US-3 | x | x | x | x | x | x |
| US-4 | x | x | x | x | x | x |
| US-5 | x | x | x | x | x | x |
| US-6 | x | x | x | x | x | x |

US-5 assume US-1 e US-2 aplicadas; permanece testável de forma independente após o apply.

## Conformidade com extensões

| Extensão | Status | Justificativa |
|----------|--------|---------------|
| Security Baseline | N/A | Desabilitada; menor privilégio via US-1, US-2, US-5 |
| Resiliency Baseline | N/A | Desabilitada |
| Property-Based Testing | N/A | Desabilitada |
