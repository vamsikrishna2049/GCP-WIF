locals {
  image = "${var.region}-docker.pkg.dev/${var.project_id}/${var.artifact_repository_id}/${var.service_name}:${var.image_tag}"

  labels = merge(var.labels, {
    environment = var.environment
    service     = var.service_name
    managed_by  = "terraform"
  })
}

resource "google_cloud_run_v2_service" "this" {
  project  = var.project_id
  name     = var.service_name
  location = var.region

  ingress              = var.ingress
  deletion_protection  = var.deletion_protection
  labels               = local.labels
  invoker_iam_disabled = var.allow_unauthenticated

  template {
    service_account                  = var.runtime_service_account_email
    timeout                          = "${var.timeout_seconds}s"
    max_instance_request_concurrency = var.concurrency

    scaling {
      min_instance_count = var.min_instances
      max_instance_count = var.max_instances
    }

    containers {
      image = local.image

      ports {
        name           = "http1"
        container_port = var.container_port
      }

      resources {
        limits = {
          cpu    = var.cpu
          memory = var.memory
        }

        cpu_idle          = var.cpu_idle
        startup_cpu_boost = true
      }

      dynamic "env" {
        for_each = var.env_vars

        content {
          name  = env.key
          value = env.value
        }
      }

      startup_probe {
        tcp_socket {
          port = var.container_port
        }

        initial_delay_seconds = 0
        period_seconds        = 10
        timeout_seconds       = 3
        failure_threshold     = 3
      }

      liveness_probe {
        http_get {
          path = var.health_check_path
        }

        period_seconds    = 30
        timeout_seconds   = 3
        failure_threshold = 3
      }
    }
  }

  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }

  lifecycle {
    ignore_changes = [
      client,
      client_version
    ]
  }
}

