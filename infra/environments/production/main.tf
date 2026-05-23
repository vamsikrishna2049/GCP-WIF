provider "google" {
  project = var.project_id
  region  = var.region
}

module "cloud_run" {
  source = "../../modules/cloud-run-service"

  project_id                    = var.project_id
  environment                   = var.environment
  region                        = var.region
  service_name                  = var.service_name
  artifact_repository_id        = var.artifact_repository_id
  image_tag                     = var.image_tag
  runtime_service_account_email = var.runtime_service_account_email

  allow_unauthenticated = var.allow_unauthenticated
  deletion_protection   = true

  min_instances = var.min_instances
  max_instances = var.max_instances
  cpu           = var.cpu
  memory        = var.memory

  env_vars = {
    APP_ENV      = var.environment
    SERVICE_NAME = var.service_name
  }
}

module "observability" {
  source = "../../modules/observability"

  project_id               = var.project_id
  environment              = var.environment
  service_name             = module.cloud_run.service_name
  notification_email       = var.notification_email
  max_instances            = var.max_instances
  p95_latency_ms_threshold = var.p95_latency_ms_threshold
  enable_alerts            = var.enable_alerts
  error_rate_threshold     = var.error_rate_threshold
}
