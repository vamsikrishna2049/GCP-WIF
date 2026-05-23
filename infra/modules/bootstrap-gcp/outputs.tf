output "project_id" {
  value = var.project_id
}

output "project_number" {
  value = data.google_project.current.number
}

output "terraform_state_bucket" {
  value = google_storage_bucket.terraform_state.name
}

output "artifact_repository_id" {
  value = google_artifact_registry_repository.docker.repository_id
}

output "deployer_service_account" {
  value = google_service_account.github_deployer.email
}

output "runtime_service_account" {
  value = google_service_account.cloud_run_runtime.email
}

output "workload_identity_provider" {
  value = google_iam_workload_identity_pool_provider.github.name
}

output "wif_pool_id" {
  value = google_iam_workload_identity_pool.github.workload_identity_pool_id
}

output "wif_provider_id" {
  value = google_iam_workload_identity_pool_provider.github.workload_identity_pool_provider_id
}
