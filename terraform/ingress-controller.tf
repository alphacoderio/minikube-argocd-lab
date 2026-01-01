# Patch the ingress-nginx-controller service to LoadBalancer
resource "null_resource" "patch_ingress_controller" {
  # This runs after Terraform initialization
  provisioner "local-exec" {
    command = <<-EOT
      kubectl patch svc ingress-nginx-controller -n ingress-nginx \
        -p '{"spec": {"type": "LoadBalancer"}}' || true
    EOT
  }

  # Re-run if any manifest changes
  triggers = {
    manifests = timestamp()
  }
}
