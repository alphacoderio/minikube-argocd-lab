# Generate namespace manifest
resource "local_file" "namespace" {
  content = templatefile("${path.module}/templates/namespace.yaml.tpl", {
    namespace = var.namespace
  })
  filename = "${path.module}/../k8s/namespace.yaml"
}

# Generate deployment manifest
resource "local_file" "deployment" {
  content = templatefile("${path.module}/templates/deployment.yaml.tpl", {
    namespace = var.namespace
    image     = var.image_name
    replicas  = var.replicas
  })
  filename = "${path.module}/../k8s/deployment.yaml"
}

# Generate service manifest
resource "local_file" "service" {
  content = templatefile("${path.module}/templates/service.yaml.tpl", {
    namespace = var.namespace
  })
  filename = "${path.module}/../k8s/service.yaml"
}
