data "github_repository" "repo" {
  full_name = "${var.github_owner}/${var.github_repo}"
}

data "github_user" "manager" {
  username = var.manager_github_username
}

locals {
  labels = {
    manager-approval-required = {
      color       = "B60205"
      description = "Manager approval is required before merge."
    }
    manager-approved = {
      color       = "0E8A16"
      description = "Manager approved this pull request."
    }
    manager-approval-timeout = {
      color       = "FBCA04"
      description = "Manager approval SLA exceeded."
    }
    auto-promotion-candidate = {
      color       = "1D76DB"
      description = "Eligible for automated environment promotion."
    }
  }
}

resource "github_issue_label" "labels" {
  for_each = local.labels

  repository  = var.github_repo
  name        = each.key
  color       = each.value.color
  description = each.value.description
}

resource "github_branch_protection" "main" {
  repository_id = data.github_repository.repo.node_id
  pattern       = var.protected_branch

  enforce_admins                  = true
  require_conversation_resolution = true
  allows_deletions                = false
  allows_force_pushes             = false

  required_pull_request_reviews {
    required_approving_review_count = 1
    require_code_owner_reviews      = var.require_code_owner_reviews
    dismiss_stale_reviews           = true
  }

  required_status_checks {
    strict   = true
    contexts = var.required_status_check_contexts
  }
}

resource "github_repository_environment" "staging" {
  repository  = var.github_repo
  environment = "staging"

  deployment_branch_policy {
    protected_branches     = true
    custom_branch_policies = false
  }
}

resource "github_repository_environment" "production" {
  repository  = var.github_repo
  environment = "production"

  wait_timer = var.production_wait_timer_minutes

  dynamic "reviewers" {
    for_each = var.require_production_environment_review ? [1] : []

    content {
      users = [data.github_user.manager.id]
    }
  }

  deployment_branch_policy {
    protected_branches     = true
    custom_branch_policies = false
  }
}
