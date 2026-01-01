resource "local_file" "ingress" {
  content = templatefile("${path.module}/templates/ingress.yaml.tpl", {
    namespace    = var.namespace
    ingress_host = var.ingress_host
    service_name = var.service_name
    app_name     = var.app_name
  })
  filename = "${path.module}/../k8s/ingress.yaml"
}
