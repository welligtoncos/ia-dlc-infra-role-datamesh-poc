#!/usr/bin/env bash
# Simulate IAM policies (US-5). Run from repo root after apply.
# If simulate fails right after apply, wait 10-20s (IAM eventual consistency) and retry.

set -euo pipefail

SOR_BUCKET="${1:?usage: $0 <sor-bucket> [outside-bucket]}"
OUTSIDE_BUCKET="${2:-this-bucket-is-not-in-the-poc-zzzz}"

GLUE_ARN="$(terraform output -raw glue_role_arn)"
ANALYTICS_ARN="$(terraform output -raw analytics_role_arn)"

sim() {
  local role="$1" action="$2" resource="$3"
  aws iam simulate-principal-policy \
    --policy-source-arn "$role" \
    --action-names "$action" \
    --resource-arns "$resource" \
    --query 'EvaluationResults[].EvalDecision' \
    --output text
}

IN="arn:aws:s3:::${SOR_BUCKET}/sample-key"
OUT="arn:aws:s3:::${OUTSIDE_BUCKET}/sample-key"

echo "Expect ALLOW glue GetObject on POC:"
sim "$GLUE_ARN" s3:GetObject "$IN"

echo "Expect DENY/implicit deny glue GetObject outside:"
sim "$GLUE_ARN" s3:GetObject "$OUT"

echo "Expect ALLOW analytics GetObject on POC:"
sim "$ANALYTICS_ARN" s3:GetObject "$IN"

echo "Expect DENY analytics PutObject on layer:"
sim "$ANALYTICS_ARN" s3:PutObject "$IN"

echo "Done."
