terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.0.2"
    }
  }
}

resource "kubernetes_deployment" "application_deployment" {
  metadata {
    name = var.name
    labels = {
      app = var.name
    }
  }

  spec {
    replicas = var.replicas

    template {
        metadata {
            labels = {
            app = var.name
            }
        }

        spec {
            container {
              image = var.image_name
              name  = var.name

              port {
                container_port = var.port
              }
            }

          dynamic "env" {
            for_each = var.environment_variables
            content {
              name  = env.key
              value = env.value
            }
          }
        }
    }

    selector {
      match_labels = {
        app = var.name
      }
    }
  }
}

resource "kubernetes_service" "kube_service" {
  metadata {
    name = var.name
  }

  spec {
    type = "LoadBalancer"
    selector = {
      app = var.name
    }

    port {
      port        = var.port
      target_port = var.port
      protocol = "TCP"
    }
  }
}