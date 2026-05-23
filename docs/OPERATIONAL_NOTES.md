# Operational Notes

## Approval SLA

The reminder workflow runs every 15 minutes. It marks a PR timed out after 120 minutes without manager approval.

## Production promotion

Production promotion is controlled by the `production` GitHub Environment wait timer. The Terraform default is 180 minutes.

## Security

Do not use GCP service account keys. WIF must be used.

## SMTP

Use a corporate SMTP relay or a provider like SendGrid. Store SMTP credentials only in GitHub Secrets.

## Auto-merge

The approval handler tries to enable auto-merge. Your repository must allow auto-merge. If not, the workflow comments on the PR and a maintainer can merge after required checks pass.

## Observability

GCP Monitoring dashboards and alerts are created per environment.
