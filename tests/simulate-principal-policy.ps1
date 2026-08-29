# Simulate IAM policies (US-5). Run from repo root after apply, with AWS CLI configured.
# If simulate fails right after apply, wait ~10-20s (IAM eventual consistency) and retry.
# Call aws via splatting — PowerShell backticks + unquoted s3:Action break the CLI.

param(
  [Parameter(Mandatory = $true)][string] $SorBucket,
  [string] $OutsideBucket = "this-bucket-is-not-in-the-poc-zzzz"
)

$ErrorActionPreference = "Stop"

$glueArn = (terraform output -raw glue_role_arn).ToString().Trim()
$analyticsArn = (terraform output -raw analytics_role_arn).ToString().Trim()

Write-Host "Glue role: $glueArn"
Write-Host "Analytics role: $analyticsArn"

function Invoke-Sim {
  param(
    [string] $RoleArn,
    [string] $IamAction,
    [string] $ResourceArn
  )
  $awsArgs = @(
    "iam", "simulate-principal-policy",
    "--policy-source-arn", $RoleArn,
    "--action-names", $IamAction,
    "--resource-arns", $ResourceArn,
    "--query", "EvaluationResults[].EvalDecision",
    "--output", "text"
  )
  & aws @awsArgs
}

$inObj = "arn:aws:s3:::${SorBucket}/sample-key"
$outObj = "arn:aws:s3:::${OutsideBucket}/sample-key"

Write-Host "Expect ALLOW glue GetObject on POC bucket:"
Invoke-Sim -RoleArn $glueArn -IamAction "s3:GetObject" -ResourceArn $inObj

Write-Host "Expect DENY (or implicit deny) glue GetObject outside POC:"
Invoke-Sim -RoleArn $glueArn -IamAction "s3:GetObject" -ResourceArn $outObj

Write-Host "Expect ALLOW analytics GetObject on POC bucket:"
Invoke-Sim -RoleArn $analyticsArn -IamAction "s3:GetObject" -ResourceArn $inObj

Write-Host "Expect DENY analytics PutObject on POC layer (read-only):"
Invoke-Sim -RoleArn $analyticsArn -IamAction "s3:PutObject" -ResourceArn $inObj

Write-Host "Done. Nao-consumidor: assume da analytics role deve falhar se o ARN nao estiver em analytics_principal_arns (teste sts:AssumeRole no console/CLI)."
