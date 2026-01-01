output "namespace" {
  description = "The namespace where resources will be deployed"
  value       = var.namespace
}

output "ingress_host" {
  description = "The ingress hostname"
  value       = var.ingress_host
}

output "ingress_url" {
  description = "The full HTTPS URL to access the application"
  value       = "https://${var.ingress_host}"
}

output "manifests_generated" {
  description = "List of generated manifest files"
  value = [
    local_file.namespace.filename,
    local_file.deployment.filename,
    local_file.service.filename,
    local_file.ingress.filename,
    local_file.tls_secret.filename,
  ]
}

output "replicas" {
  description = "Number of pod replicas"
  value       = var.replicas
}

output "tls_certificate_cn" {
  description = "Common Name (CN) of the generated TLS certificate"
  value       = var.ingress_host
}
