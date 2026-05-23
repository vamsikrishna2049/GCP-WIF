# Production Cloud Run CI/CD on GCP with Terraform, GitHub Actions, WIF, Manager Approval, Reminders, and Observability

This repository is a production-ready starter kit for deploying a Google Cloud Run service using:

- Terraform modules
- GitHub Actions CI/CD
- Workload Identity Federation
- Multi-environment deployment: staging and production
- Manager pull request approval gate
- Manager notification on branch push
- Email reminders every 15 minutes until approval timeout
- 2-hour approval SLA labeling
- 3-hour delayed promotion to the next environment through GitHub Environment wait timer
- GCP Observability using Cloud Monitoring alert policies, notification channels, and dashboards
- Multi-stage Dockerfile for smaller container images

---

## 1. 🔍 Problem Understanding

You want the following workflow:

1. Developer pushes code to a non-main branch.
2. A pull request is automatically created or updated.
3. The manager is requested as PR reviewer.
4. The manager receives an email notification.
5. If the manager does not approve, reminder emails are sent every 15 minutes.
6. If approval is not provided within 2 hours, the PR is labeled as timed out.
7. Only after manager approval can code be merged into the protected branch.
8. After merge, staging deploys through GitHub Actions using GCP Workload Identity Federation.
9. After a 3-hour delay, the same pipeline is allowed to move to the next environment, production.
10. GCP Cloud Monitoring observes the Cloud Run service.

Important production decision:

- The 2-hour manager approval SLA is handled by PR automation and branch protection.
- The 3-hour next-environment gate is handled by GitHub Environment deployment protection wait timer, not by a sleeping shell loop.
- GCP access uses WIF only. No service account keys are used.

---

## 2. 🏗️ Architecture Design

```text
Developer branch push
  |
  v
GitHub Actions: PR Requestor
  |
  | create/update PR
  | request manager review
  | send email
  v
Manager PR approval gate
  |
  | reminders every 15 minutes until approved or timed out
  v
Protected main branch
  |
  | merge only after manager approval + checks
  v
Deploy staging with GitHub OIDC -> GCP WIF
  |
  | GitHub Environment wait timer: 180 minutes
  v
Deploy production with GitHub OIDC -> GCP WIF
```

### Key components

| Component | Purpose |
|---|---|
| `modules/bootstrap-gcp` | Enables APIs, creates state bucket, Artifact Registry, WIF, deployer and runtime service accounts |
| `modules/cloud-run-service` | Deploys Cloud Run v2 service |
| `modules/observability` | Creates Cloud Monitoring alert policies, email notification channel, and dashboard |
| `modules/github-governance` | Creates GitHub labels, environments, branch protection, and wait timer |
| `pr-request-manager.yml` | Creates PR and notifies manager |
| `manager-approval-reminder.yml` | Sends reminder emails every 15 minutes |
| `manager-approval-handler.yml` | Handles manager approval and enables auto-merge |
| `deploy-cloud-run.yml` | Builds, pushes, and deploys Cloud Run to staging and production |

---

## 3. 🔐 Security Design

### Authentication

GitHub Actions authenticates to Google Cloud using OIDC and Workload Identity Federation.

No JSON keys are stored in GitHub.

Required job permissions:

```yaml
permissions:
  contents: read
  id-token: write
```

### WIF trust model

Each environment has its own WIF provider and deployer service account.

The WIF provider checks:

```text
assertion.repository_owner == "<github-owner>"
assertion.repository == "<github-owner>/<github-repo>"
assertion.sub == "repo:<github-owner>/<github-repo>:environment:<environment>"
```

This means a production deploy token is only valid when the GitHub job runs inside the `production` GitHub Environment.

### IAM model

| Identity | Scope | Role |
|---|---|---|
| GitHub WIF principal | Deployer service account | `roles/iam.workloadIdentityUser` |
| Deployer service account | Project | `roles/run.admin` |
| Deployer service account | Artifact Registry repo | `roles/artifactregistry.writer` |
| Deployer service account | Runtime service account | `roles/iam.serviceAccountUser` |
| Deployer service account | Terraform state bucket | `roles/storage.objectAdmin` |
| Deployer service account | Monitoring | `roles/monitoring.editor` |
| Cloud Run runtime service account | App dependencies only | Add only what app needs |

The runtime service account intentionally does not receive deployer permissions.

### GitHub secrets and variables

Create these as repository or environment variables/secrets.

Repository variables:

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

Staging environment variables:

```text
GCP_PROJECT_ID
GCP_PROJECT_NUMBER
TF_STATE_BUCKET
DEPLOYER_SERVICE_ACCOUNT
RUNTIME_SERVICE_ACCOUNT
WIF_POOL_ID
WIF_PROVIDER_ID
```

Production environment variables:

```text
GCP_PROJECT_ID
GCP_PROJECT_NUMBER
TF_STATE_BUCKET
DEPLOYER_SERVICE_ACCOUNT
RUNTIME_SERVICE_ACCOUNT
WIF_POOL_ID
WIF_PROVIDER_ID
```

---

## 4. 📁 Project Structure

```text
.
├── app/
│   ├── Dockerfile
│   ├── requirements.txt
│   └── src/
│       └── main.py
├── infra/
│   ├── bootstrap/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── staging.tfvars.example
│   │   └── production.tfvars.example
│   ├── github-governance/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── terraform.tfvars.example
│   ├── environments/
│   │   ├── staging/
│   │   └── production/
│   └── modules/
│       ├── bootstrap-gcp/
│       ├── cloud-run-service/
│       ├── observability/
│       └── github-governance/
├── scripts/
│   ├── notify_manager.py
│   └── local_bootstrap.sh
└── .github/
    ├── CODEOWNERS
    └── workflows/
        ├── pr-request-manager.yml
        ├── manager-approval-reminder.yml
        ├── manager-approval-handler.yml
        └── deploy-cloud-run.yml
```

---

## 5. ⚙️ Terraform Code

Terraform code is fully modular and located under `infra/modules`.

### Bootstrap GCP

Run once per environment:

```bash
cd infra/bootstrap
terraform init
terraform apply -var-file=staging.tfvars
terraform apply -var-file=production.tfvars
```

This creates:

- Required GCP APIs
- GCS state bucket
- Artifact Registry repository
- GitHub WIF pool and provider
- GitHub deployer service account
- Cloud Run runtime service account
- least-privilege IAM bindings

### GitHub governance

Run once per repository:

```bash
cd infra/github-governance
export GITHUB_TOKEN="<admin-token-or-github-app-token>"
terraform init
terraform apply
```

This creates:

- labels used by the automation
- protected `main` branch
- required PR reviews
- staging and production environments
- production wait timer of 180 minutes

The production wait timer enforces the "after 3 hours, move to next environment" rule without keeping a runner busy.

---

## 6. 🔄 GitHub Actions Pipeline

### Workflow behavior

| Workflow | Trigger | Behavior |
|---|---|---|
| `pr-request-manager.yml` | Push to non-main branch | Creates PR, requests manager review, sends email |
| `manager-approval-reminder.yml` | Every 15 minutes | Emails reminders for pending PRs |
| `manager-approval-handler.yml` | Manager PR approval | Labels approved PR and enables auto-merge |
| `deploy-cloud-run.yml` | Push to `main` | Deploys staging, then production after 3-hour environment wait timer |

### Why not use `sleep 3h`?

A sleeping GitHub Actions job is operationally weak:

- consumes runner time
- can be cancelled accidentally
- does not express governance clearly
- does not integrate cleanly with deployment approval UI

GitHub Environment wait timers are the correct control for delayed promotion.

---

## 7. 🚀 Deployment Flow

### First-time setup

1. Replace all placeholder values in:
   - `infra/bootstrap/*.tfvars`
   - `infra/github-governance/terraform.tfvars`
   - GitHub repository/environment variables and secrets

2. Bootstrap staging and production GCP projects.

3. Apply GitHub governance Terraform.

4. Push a feature branch:

   ```bash
   git checkout -b feature/demo-change
   git add .
   git commit -m "demo: test manager approval flow"
   git push origin feature/demo-change
   ```

5. GitHub creates or updates a PR and emails the manager.

6. Manager approves PR.

7. Auto-merge is enabled. If repository auto-merge is disabled, the workflow comments with a manual merge instruction.

8. Merge to `main` triggers staging deployment.

9. Production deployment waits 180 minutes through the `production` GitHub Environment.

---

## 8. 📊 Observability & Monitoring

The observability module creates:

- Cloud Monitoring email notification channel
- 5xx alert
- high latency alert
- instance saturation alert
- Cloud Run dashboard

Metrics monitored:

```text
run.googleapis.com/request_count
run.googleapis.com/request_latencies
run.googleapis.com/container/instance_count
```

Recommended operational SLOs:

| Signal | Suggested target |
|---|---|
| Availability | 99.9% for production |
| p95 latency | service-specific, often <500ms for APIs |
| 5xx rate | <1% over 5 minutes |
| Saturation | max instances should not be continuously reached |

---

## 9. 💰 Cost Optimization Tips

- Use `min_instances = 0` in staging.
- Use `min_instances = 1` in production only if cold starts violate SLOs.
- Enable Artifact Registry cleanup policies.
- Use small multi-stage container images.
- Tune Cloud Run concurrency before increasing CPU.
- Set `max_instances` to protect budget.
- Avoid excessive application logs in production.
- Use separate staging and production projects with separate budgets.

---

## 10. ⚠️ Common Pitfalls

### 1. Manager username mismatch

`MANAGER_GITHUB_USERNAME` must match the GitHub login exactly.

### 2. GitHub environment name mismatch

The WIF condition depends on:

```text
repo:<owner>/<repo>:environment:staging
repo:<owner>/<repo>:environment:production
```

If the workflow environment name does not match Terraform, authentication fails.

### 3. Missing `id-token: write`

Without this permission, GitHub cannot request the OIDC token.

### 4. SMTP secrets missing

The notification script intentionally fails if SMTP secrets are missing, unless `NOTIFICATION_DRY_RUN=true` is set.

### 5. Repository auto-merge disabled

The approval handler tries to enable auto-merge. If auto-merge is disabled at repository level, it will leave a PR comment instead.

### 6. Branch protection too weak

Do not allow direct push to `main`. Require PR review and status checks.

### 7. Runtime service account over-permissioned

Never reuse the deployer service account as Cloud Run runtime service account.

### 8. Public Cloud Run by accident

This template defaults to authenticated Cloud Run. Make it public only intentionally.

---

## 11. 🔄 Alternatives / Enhancements

- Use a GitHub App instead of a personal admin token for GitHub Terraform governance.
- Promote immutable image digests from staging to production rather than rebuilding.
- Add SAST, dependency scanning, container scanning, and Terraform policy checks.
- Add Cloud Deploy for advanced promotion strategies, while still keeping GitHub Actions as orchestrator.
- Add canary traffic shifting in Cloud Run.
- Add Secret Manager integration for app secrets.
- Add Cloud Armor and external HTTPS Load Balancer for public production APIs.
- Add PagerDuty, Opsgenie, or Slack notification channels.
