provider "kubernetes" {
  config_path = var.kube_config
}

provider "helm" {
  kubernetes {
    config_path = pathexpand(var.kube_config)
  }
}

#https://github.com/Azure/AKS/issues/2907#issuecomment-1109759262
resource "helm_release" "nginx_controller" {
  chart      = "ingress-nginx"
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  namespace        = var.namespace
  create_namespace = true

  values = [
    "${file("nginx_ingress_values.yaml")}"
  ]
}
