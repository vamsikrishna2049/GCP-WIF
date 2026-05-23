variable "project_id" {
  type = string
}

variable "environment" {
  type = string
}

variable "region" {
  type    = string
  default = "us-central1"
}

variable "state_bucket_location" {
  type    = string
  default = "US"
}

variable "tf_state_bucket" {
  type = string
}

variable "github_owner" {
  type = string
}

variable "github_repo" {
  type = string
}

variable "github_environment" {
  type = string
}

variable "service_name" {
  type = string
}

variable "artifact_repository_id" {
  type = string
}

variable "keep_recent_images" {
  type    = number
  default = 30
}

variable "runtime_service_account_id" {
  type = string
}

variable "wif_pool_id" {
  type = string
}

variable "wif_provider_id" {
  type = string
}
