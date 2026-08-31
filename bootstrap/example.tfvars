# Placeholders — copy to terraform.tfvars in this directory (gitignored).
# Apply once per AWS account (dev, hom, or prod) with admin credentials.

project_prefix = "datamesh-poc"
environment    = "dev"
aws_region     = "sa-east-1"

github_owner = "REPLACE-github-org-or-user"
github_repo  = "ia-dlc-infra-role-datamesh-poc"

# IDs imutaveis no claim sub (org/repo com "Include ... IDs in the OIDC subject claim").
# Copie do token: repo:OWNER@OWNER_ID/REPO@REPO_ID:environment:dev
github_owner_id = "REPLACE-github-owner-id"
github_repo_id  = "REPLACE-github-repo-id"

# github_environment defaults to environment. Set only if it must differ (will fail precondition).
# github_environment = "dev"

# If the conventional S3 name is globally taken:
# state_bucket_name = "REPLACE-globally-unique-tfstate-bucket"
# lock_table_name   = "REPLACE-optional-lock-table"
