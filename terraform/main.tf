terraform {
  required_version = ">= 1.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "minikube"
}

# Production Namespace
resource "kubernetes_namespace" "web_api" {
  metadata {
    name = var.namespace

    labels = {
      environment = "production"
      managed-by  = "terraform"
    }
  }
}

# Deployment
resource "kubernetes_deployment" "web_api" {
  metadata {
    name      = "web-api"
    namespace = kubernetes_namespace.production.metadata[0].name

    labels = {
      app = "web-api"
    }
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = "web-api"
      }
    }

    template {
      metadata {
        labels = {
          app = "web-api"
        }
      }

      spec {
        security_context {
          run_as_non_root = true
          run_as_user     = 1000
          fs_group        = 1000
        }

        container {
          name  = "web-api"
          image = var.image_name

          port {
            container_port = 8000
            protocol       = "TCP"
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = 8000
            }
            initial_delay_seconds = 10
            period_seconds        = 10
          }

          readiness_probe {
            http_get {
              path = "/health"
              port = 8000
            }
            initial_delay_seconds = 5
            period_seconds        = 5
          }

          resources {
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "256Mi"
            }
          }

          security_context {
            allow_privilege_escalation = false
            read_only_root_filesystem  = false
            run_as_non_root            = true
            run_as_user                = 1000
          }
        }
      }
    }
  }

  depends_on = [kubernetes_namespace.production]
}

# Service
resource "kubernetes_service" "web_api" {
  metadata {
    name      = "web-api-service"
    namespace = kubernetes_namespace.production.metadata[0].name
  }

  spec {
    selector = {
      app = "web-api"
    }

    port {
      port        = 80
      target_port = 8000
      protocol    = "TCP"
    }

    type = "ClusterIP"
  }

  depends_on = [kubernetes_deployment.web_api]
}

# Ingress
resource "kubernetes_ingress_v1" "web_api" {
  metadata {
    name      = "web-api-ingress"
    namespace = kubernetes_namespace.production.metadata[0].name

    annotations = {
      "nginx.ingress.kubernetes.io/ssl-redirect"       = "true"
      "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"
    }
  }

  spec {
    ingress_class_name = "nginx"

    tls {
      hosts       = [var.ingress_host]
      secret_name = "web-api-tls"
    }

    rule {
      host = var.ingress_host

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service.web_api.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [kubernetes_service.web_api]
}
