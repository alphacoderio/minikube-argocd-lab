resource "tls_private_key" "web_api" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "web_api" {
  private_key_pem = tls_private_key.web_api.private_key_pem

  subject {
    common_name  = var.ingress_host
    organization = "web-api"
  }

  validity_period_hours = 8760

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "local_file" "tls_secret" {
  content = templatefile("${path.module}/templates/tls-secret.yaml.tpl", {
    namespace = var.namespace
    tls_crt   = base64encode(tls_self_signed_cert.web_api.cert_pem)
    tls_key   = base64encode(tls_private_key.web_api.private_key_pem)
  })
  filename = "${path.module}/../k8s/tls-secret.yaml"
}
