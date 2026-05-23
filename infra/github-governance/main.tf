provider "github" {
  owner = var.github_owner
}

module "github_governance" {
  source = "../modules/github-governance"

  github_owner                         = var.github_owner
  github_repo                          = var.github_repo
  manager_github_username              = var.manager_github_username
  protected_branch                     = var.protected_branch
  require_code_owner_reviews           = var.require_code_owner_reviews
  required_status_check_contexts       = var.required_status_check_contexts
  production_wait_timer_minutes        = var.production_wait_timer_minutes
  require_production_environment_review = var.require_production_environment_review
}
