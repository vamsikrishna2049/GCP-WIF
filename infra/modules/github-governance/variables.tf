variable "github_owner" {
  type = string
}

variable "github_repo" {
  type = string
}

variable "manager_github_username" {
  type = string
}

variable "protected_branch" {
  type    = string
  default = "main"
}

variable "require_code_owner_reviews" {
  type    = bool
  default = true
}

variable "required_status_check_contexts" {
  type        = list(string)
  default     = []
  description = "Required status check contexts. Keep empty during initial bootstrap, then add exact check names after first run."
}

variable "production_wait_timer_minutes" {
  type    = number
  default = 180
}

variable "require_production_environment_review" {
  type        = bool
  default     = false
  description = "Set true if production deploy also requires manager review after the 3-hour wait."
}
