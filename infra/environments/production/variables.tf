variable "project_id" {
  type = string
}

variable "environment" {
  type = string
}

variable "region" {
  type = string
}

variable "service_name" {
  type = string
}

variable "artifact_repository_id" {
  type = string
}

variable "image_tag" {
  type = string
}

variable "runtime_service_account_email" {
  type = string
}

variable "notification_email" {
  type    = string
  default = ""
}

variable "allow_unauthenticated" {
  type    = bool
  default = false
}

variable "min_instances" {
  type = number
}

variable "max_instances" {
  type = number
}

variable "cpu" {
  type = string
}

variable "memory" {
  type = string
}

variable "p95_latency_ms_threshold" {
  type    = number
  default = 1000
}

variable "enable_alerts" {
  type    = bool
  default = true
  description = "Enable Cloud Monitoring alert policies"
}

variable "error_rate_threshold" {
  type    = number
  default = 1
  description = "5xx error rate threshold (errors per second)"
}
