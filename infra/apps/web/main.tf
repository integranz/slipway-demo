# App layer for `web`: one container app in the shared environment (infra/foundation). The container app is
# named exactly after the app so other apps reach it as http://web through the environment proxy.

resource "azurerm_container_app" "this" {
  name                         = "web"
  container_app_environment_id = data.azurerm_container_app_environment.this.id
  resource_group_name          = data.azurerm_resource_group.env.name
  revision_mode                = "Single"
  tags                         = local.tags

  identity {
    type         = "UserAssigned"
    identity_ids = [data.azurerm_user_assigned_identity.apps.id]
  }

  registry {
    server   = data.azurerm_container_registry.this.login_server
    identity = data.azurerm_user_assigned_identity.apps.id
  }

  ingress {
    external_enabled           = true
    target_port                = 8080
    transport                  = "auto"
    allow_insecure_connections = false

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  template {
    min_replicas = 1
    max_replicas = 2

    container {
      name   = "web"
      image  = "${data.azurerm_container_registry.this.login_server}/adlc-demo/web:${var.image_tag}"
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name  = "APP_VERSION"
        value = var.image_tag
      }

      liveness_probe {
        transport               = "HTTP"
        port                    = 8080
        path                    = "/"
        interval_seconds        = 10
        initial_delay           = 5
        failure_count_threshold = 3
      }

      readiness_probe {
        transport               = "HTTP"
        port                    = 8080
        path                    = "/"
        interval_seconds        = 5
        failure_count_threshold = 3
        success_count_threshold = 1
      }
    }
  }
}
