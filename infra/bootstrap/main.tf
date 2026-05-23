provider "google" {
  project = var.project_id
  region  = var.region
}

module "bootstrap" {
  source = "../modules/bootstrap-gcp"

  project_id                 = var.project_id
  environment                = var.environment
  region                     = var.region
  state_bucket_location      = var.state_bucket_location
  tf_state_bucket            = var.tf_state_bucket
  github_owner               = var.github_owner
  github_repo                = var.github_repo
  github_environment         = var.github_environment
  service_name               = var.service_name
  artifact_repository_id     = var.artifact_repository_id
  keep_recent_images         = var.keep_recent_images
  runtime_service_account_id = var.runtime_service_account_id
  wif_pool_id                = var.wif_pool_id
  wif_provider_id            = var.wif_provider_id
}
