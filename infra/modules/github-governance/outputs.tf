output "repository" {
  value = data.github_repository.repo.full_name
}

output "manager_user_id" {
  value = data.github_user.manager.id
}

output "production_wait_timer_minutes" {
  value = var.production_wait_timer_minutes
}
