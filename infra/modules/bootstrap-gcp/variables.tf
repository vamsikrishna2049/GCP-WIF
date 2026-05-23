variable "project_id" {
  type        = string
  description = "GCP project ID."
}

variable "environment" {
  type        = string
  description = "Environment name, such as staging or production."
}

variable "region" {
  type        = string
  description = "GCP region."
}

variable "state_bucket_location" {
  type        = string
  default     = "US"
  description = "Location for Terraform state bucket."
}

variable "tf_state_bucket" {
  type        = string
  description = "Globally unique GCS bucket name for Terraform state."
}

variable "state_versions_to_keep" {
  type        = number
  default     = 30
  description = "Number of state object versions to retain."
}

variable "github_owner" {
  type        = string
  description = "GitHub org or user."
}

variable "github_repo" {
  type        = string
  description = "GitHub repository name."
}

variable "github_environment" {
  type        = string
  description = "GitHub Environment name used in OIDC subject."
}

variable "service_name" {
  type        = string
  description = "Cloud Run service name."
}

variable "artifact_repository_id" {
  type        = string
  description = "Artifact Registry repository ID."
}

variable "keep_recent_images" {
  type        = number
  default     = 30
  description = "Recent images to keep in Artifact Registry cleanup policy."
}

variable "deployer_service_account_id" {
  type        = string
  default     = "github-cloudrun-deployer"
  description = "Service account ID for GitHub deployer."
}

variable "runtime_service_account_id" {
  type        = string
  description = "Service account ID for Cloud Run runtime."
}

variable "wif_pool_id" {
  type        = string
  description = "Workload Identity Pool ID."
}

variable "wif_provider_id" {
  type        = string
  description = "Workload Identity Pool Provider ID."
}
