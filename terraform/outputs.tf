output "namespace" {
  description = "The namespace where resources are deployed"
  value       = kubernetes_namespace.web_api.metadata[0].name
}

output "service_name" {
  description = "The name of the Kubernetes service"
  value       = kubernetes_service.web_api.metadata[0].name
}

output "deployment_name" {
  description = "The name of the Kubernetes deployment"
  value       = kubernetes_deployment.web_api.metadata[0].name
}

output "ingress_host" {
  description = "The ingress hostname"
  value       = var.ingress_host
}

output "ingress_url" {
  description = "The full HTTPS URL to access the application"
  value       = "https://${var.ingress_host}"
}
