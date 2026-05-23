output "cloud_run_service_uri" {
  value = module.cloud_run.service_uri
}

output "cloud_run_image" {
  value = module.cloud_run.image
}

output "observability_dashboard_id" {
  value = module.observability.dashboard_id
}
