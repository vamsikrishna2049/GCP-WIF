# Setup Guide

## 1. Configure repository variables

Repository-level variables:

```text
MANAGER_GITHUB_USERNAME
GCP_REGION
SERVICE_NAME
ARTIFACT_REPOSITORY_ID
```

Repository secrets:

```text
MANAGER_EMAIL
SMTP_HOST
SMTP_PORT
SMTP_USERNAME
SMTP_PASSWORD
SMTP_FROM
```

## 2. Bootstrap GCP

Copy example tfvars files:

```bash
cp infra/bootstrap/staging.tfvars.example infra/bootstrap/staging.tfvars
cp infra/bootstrap/production.tfvars.example infra/bootstrap/production.tfvars
```

Edit values, then run:

```bash
cd infra/bootstrap
terraform init
terraform apply -var-file=staging.tfvars
terraform apply -var-file=production.tfvars
```

## 3. Configure GitHub environments

Use the bootstrap outputs to create these environment variables for both `staging` and `production`:

```text
GCP_PROJECT_ID
GCP_PROJECT_NUMBER
TF_STATE_BUCKET
DEPLOYER_SERVICE_ACCOUNT
RUNTIME_SERVICE_ACCOUNT
WIF_POOL_ID
WIF_PROVIDER_ID
```

## 4. Apply GitHub governance

```bash
cp infra/github-governance/terraform.tfvars.example infra/github-governance/terraform.tfvars
cd infra/github-governance
export GITHUB_TOKEN="<admin-token-or-github-app-token>"
terraform init
terraform apply
```

## 5. Test the flow

```bash
git checkout -b feature/test-manager-approval
git commit --allow-empty -m "test: manager approval flow"
git push origin feature/test-manager-approval
```

Expected:

1. PR is created.
2. Manager is requested as reviewer.
3. Email is sent.
4. Reminders run every 15 minutes.
5. Manager approval allows merge.
6. Merge to main deploys staging.
7. Production waits 180 minutes before deploy.
