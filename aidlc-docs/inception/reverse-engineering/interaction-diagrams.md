# Diagramas de Interação

Como as transações de negócio são implementadas entre componentes do código atual.

## T1 Provisionar identidade

```mermaid
sequenceDiagram
  participant Eng as Engenheiro
  participant TF as Terraform root
  participant AWS as AWS IAM
  Eng->>TF: init fmt validate plan apply
  TF->>AWS: GetCallerIdentity
  TF->>AWS: CreateRole glue e analytics
  TF->>AWS: CreatePolicy e AttachRolePolicy
  TF-->>Eng: glue_role_arn analytics_role_arn
```

### Alternativa em texto

```
Engenheiro -> Terraform -> IAM CreateRole/Policy
Engenheiro <- outputs ARNs
```

## T2 Glue Job assume glue-role (runtime Projeto 2)

```mermaid
sequenceDiagram
  participant Job as Glue Job
  participant STS as STS
  participant Role as glue-role
  Job->>STS: AssumeRole glue.amazonaws.com
  STS->>Role: trust SourceAccount
  Role-->>Job: credentials temporarias
```

## T3 Analista assume analytics-role

```mermaid
sequenceDiagram
  participant User as Principal em analytics_principal_arns
  participant STS as STS
  participant Role as analytics-role
  User->>STS: AssumeRole
  STS->>Role: trust lista de ARNs mesma conta
  Role-->>User: credentials temporarias
```

## T4 Validação menor privilégio

```mermaid
sequenceDiagram
  participant Eng as Engenheiro
  participant Script as tests simulate
  participant IAM as IAM SimulatePrincipalPolicy
  Eng->>Script: passa SorBucket
  Script->>IAM: GetObject in-scope ALLOW
  Script->>IAM: GetObject out-of-scope DENY
  Script->>IAM: Analytics PutObject camada DENY
```

## T5 Destroy

```mermaid
sequenceDiagram
  participant Eng as Engenheiro
  participant TF as Terraform
  participant IAM as AWS IAM
  Eng->>TF: destroy
  TF->>IAM: detach delete policy e role
  Note over TF: buckets Projeto 2 nao sao destruidos
```
