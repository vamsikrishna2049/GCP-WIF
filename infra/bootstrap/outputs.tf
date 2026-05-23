output "project_id" {
  value = module.bootstrap.project_id
}

output "project_number" {
  value = module.bootstrap.project_number
}

output "terraform_state_bucket" {
  value = module.bootstrap.terraform_state_bucket
}

output "artifact_repository_id" {
  value = module.bootstrap.artifact_repository_id
}

output "deployer_service_account" {
  value = module.bootstrap.deployer_service_account
}

output "runtime_service_account" {
  value = module.bootstrap.runtime_service_account
}

output "workload_identity_provider" {
  value = module.bootstrap.workload_identity_provider
}

output "wif_pool_id" {
  value = module.bootstrap.wif_pool_id
}

output "wif_provider_id" {
  value = module.bootstrap.wif_provider_id
}
