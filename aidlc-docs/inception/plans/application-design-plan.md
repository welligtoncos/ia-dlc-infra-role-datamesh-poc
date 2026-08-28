# Application Design Plan — InfraRoles Mini

**Estágio**: INCEPTION — Design da Aplicação (planejamento)
**Fontes**: `requirements.md`, `stories.md`, `personas.md`, `execution-plan.md`
**Adaptação**: IaC Terraform (sem API HTTP). Componentes = blocos lógicos de identidade; “métodos” = interfaces (entradas/saídas), não classes.

Preencha cada `[Answer]:`. A geração dos artefatos em `aidlc-docs/inception/application-design/` só começa após as respostas (e esclarecimentos, se houver).

---

## Contexto já fechado (não perguntar de novo)

- Root module plano; um arquivo por role (`glue.tf`, `analytics.tf`); sem `modules/iam-roles`
- Sem role de Acesso; output `access_role_arn = null`
- Buckets só referenciados (`sor` / `sot` / `spec` + Athena results)
- Glue Job e Não-consumidor são atores de aceite, não componentes de software

---

## Perguntas de design

## Question 1
Quais limites de componentes lógicos devem aparecer em `components.md`?

A) Quatro: `TerraformBootstrap` (versions/provider/vars/tags), `GlueIdentity`, `AnalyticsIdentity`, `OutputContract`

B) Três: `GlueIdentity`, `AnalyticsIdentity`, `OutputContract` — bootstrap não é componente, só suporte do root

C) Dois: `GlueIdentity` e `AnalyticsIdentity` — outputs e bootstrap não são componentes (só arquivos do root)

X) Other (please describe after [Answer]: tag below)

[Answer]:B	3 componentes (Glue, Analytics, OutputContract); bootstrap é suporte

---

## Question 2
Como representar “métodos” / interfaces em `component-methods.md` (não há classes)?

A) Interface por componente = variáveis de entrada + atributos de saída (ex.: GlueIdentity entra buckets/prefix; sai `role_arn`)

B) Interface = operações Terraform do root (`plan`, `apply`, `output`, `destroy`) e os componentes só declaram recursos, sem “métodos” próprios

C) Híbrido: root expõe `plan`/`apply`/`output`/`destroy`; cada identidade declara entradas (vars) e saída (`role_arn`)

X) Other (please describe after [Answer]: tag below)

[Answer]:C	Interface em 2 níveis: ciclo Terraform + entradas/saída por componente

---

## Question 3
O que é a “camada de serviço” em `services.md`?

A) Um serviço `IdentityPlatform`: um único `terraform apply` orquestra bootstrap + as duas identidades + outputs

B) Sem serviço: só componentes; o root Terraform é orquestrador implícito, documentado em uma frase em `services.md`

C) Dois “serviços” lógicos (Glue vs Analytics) mesmo com um único apply — orquestração só compartilhando variáveis

X) Other (please describe after [Answer]: tag below)

[Answer]:A	Serviço lógico IdentityPlatform = o apply coeso

---

## Question 4
Qual o acoplamento permitido entre GlueIdentity e AnalyticsIdentity?

A) Zero dependência IAM entre roles; compartilham só variáveis de naming e nomes de buckets (acoplamento de configuração)

B) AnalyticsIdentity pode referenciar o ARN/nome da GlueIdentity (dependência declarada)

C) Policy documents compartilhados (mesmo conjunto de ações S3), parametrizados por role

X) Other (please describe after [Answer]: tag below)

[Answer]:A	Roles independentes; só acoplamento de configuração

---

## Question 5
O `OutputContract` (`glue_role_arn`, `analytics_role_arn`, `access_role_arn=null`) depende de quais componentes?

A) Depende de GlueIdentity e AnalyticsIdentity (lê os ARNs); `access_role_arn` é constante `null` no próprio contrato

B) Não é componente; cada identidade publica seu output e o null de Acesso vive num `outputs.tf` sem dono lógico

C) Contrato é o único ponto visível ao Projeto 2; identidades não “exportam” nada além do que o contrato agrega

X) Other (please describe after [Answer]: tag below)

[Answer]:A	OutputContract depende das 2 identidades; null é constante

---

## Question 6
Onde fica a validação US-5 (`simulate-principal-policy`, P2 vs Não-consumidor) neste design de aplicação?

A) Fora dos componentes de runtime — preocupação de Build and Test / verificação, só mencionada como dependência de qualidade

B) Componente lógico `IdentityVerification` (não vira resource AWS; descreve o contrato de teste)

C) Métodos de verificação anexados a GlueIdentity e AnalyticsIdentity (ex.: `assertLeastPrivilege`)

X) Other (please describe after [Answer]: tag below)

[Answer]:A	Validação US-5 é Build/Test, não componente

---

## Question 7
Padrão de composição do root (já decidido um arquivo por role — isto só fecha o diagrama de dependências)?

A) Composição plana: root referencia os quatro (ou os componentes da Q1) sem camada extra

B) Fachada `IdentityPlatform` na frente dos componentes, mesmo sem submódulo Terraform

X) Other (please describe after [Answer]: tag below)

[Answer]:A	Composição plana; IdentityPlatform é rótulo, não camada

---

## Checklist de execução (após respostas + aprovação do plano, se pedida)

- [x] Carregar requirements, stories e este plano
- [x] Gerar `aidlc-docs/inception/application-design/components.md`
- [x] Gerar `aidlc-docs/inception/application-design/component-methods.md` (interfaces, sem regras de policy detalhadas)
- [x] Gerar `aidlc-docs/inception/application-design/services.md`
- [x] Gerar `aidlc-docs/inception/application-design/component-dependency.md` (matriz + mermaid + alternativa texto)
- [x] Gerar `aidlc-docs/inception/application-design/application-design.md` (consolidado)
- [x] Validar: US-1..US-6 cobertas; `access_role_arn=null`; sem role de Acesso; sem criar buckets
- [x] Atualizar checkboxes e `aidlc-state.md`

---

## Regras da geração

- Idioma: português
- Sem lista de `aws_iam_*` resources (isso é Construction)
- Extensões Security / Resiliency / PBT: N/A
