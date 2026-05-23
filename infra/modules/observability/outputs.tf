output "dashboard_id" {
  value = google_monitoring_dashboard.cloud_run.id
}

output "notification_channel_ids" {
  value = local.notification_channels
}
