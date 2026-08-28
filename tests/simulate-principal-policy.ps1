# Simulate IAM policies (US-5). Run from repo root after apply, with AWS CLI configured.
# If simulate fails right after apply, wait ~10-20s (IAM eventual consistency) and retry.

param(
  [Parameter(Mandatory = $true)][string] $SorBucket,
  [Parameter(Mandatory = $true)][string] $OutsideBucket = "this-bucket-is-not-in-the-poc-zzzz"
)

$ErrorActionPreference = "Stop"

$glueArn = terraform output -raw glue_role_arn
$analyticsArn = terraform output -raw analytics_role_arn

Write-Host "Glue role: $glueArn"
Write-Host "Analytics role: $analyticsArn"

function Invoke-Sim {
  param($RoleArn, $Action, $Resource)
  aws iam simulate-principal-policy `
    --policy-source-arn $RoleArn `
    --action-names $Action `
    --resource-arns $Resource `
    --query "EvaluationResults[].EvalDecision" `
    --output text
}

$inObj = "arn:aws:s3::://${SorBucket}/sample-key"
$outObj = "arn:aws:s3::://${OutsideBucket}/sample-key"

Write-Host "Expect ALLOW glue GetObject on POC bucket:"
Invoke-Sim -RoleArn $glueArn -Action "s3:GetObject" -Resource $inObj

Write-Host "Expect DENY (or implicit deny) glue GetObject outside POC:"
Invoke-Sim -RoleArn $glueArn -Action "s3:GetObject" -Resource $outObj

Write-Host "Expect ALLOW analytics GetObject on POC bucket:"
Invoke-Sim -RoleArn $analyticsArn -Action "s3:GetObject" -Resource $inObj

Write-Host "Expect DENY analytics PutObject on POC layer (read-only):"
Invoke-Sim -RoleArn $analyticsArn -Action "s3:PutObject" -Resource $inObj

Write-Host "Done. Nao-consumidor: assume da analytics role deve falhar se o ARN nao estiver em analytics_principal_arns (teste sts:AssumeRole no console/CLI)."
