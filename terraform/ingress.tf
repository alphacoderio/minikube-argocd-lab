resource "local_file" "ingress" {
  content = templatefile("${path.module}/templates/ingress.yaml.tpl", {
    namespace    = var.namespace
    ingress_host = var.ingress_host
  })
  filename = "${path.module}/../k8s/ingress.yaml"
}
