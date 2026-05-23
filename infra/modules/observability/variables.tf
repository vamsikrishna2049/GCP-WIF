variable "project_id" {
  type = string
}

variable "environment" {
  type = string
}

variable "service_name" {
  type = string
}

variable "notification_email" {
  type        = string
  default     = ""
  description = "Email address for Cloud Monitoring notifications. Leave empty to skip channel creation."
}

variable "enable_alerts" {
  type    = bool
  default = true
}

variable "error_rate_threshold" {
  type        = number
  default     = 1
  description = "5xx responses per second over the alert window."
}

variable "p95_latency_ms_threshold" {
  type        = number
  default     = 1000
  description = "p95 latency threshold in milliseconds."
}

variable "max_instances" {
  type        = number
  description = "Cloud Run max instance count used for saturation alert threshold."
}
