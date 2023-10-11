provider "kubernetes" {
  config_path = var.kube_config
}
provider "helm" {
    kubernetes {
    config_path = pathexpand(var.kube_config)
  }
}
resource "kubernetes_namespace" "jenkins" {
  metadata {
    name = var.namespace
  }
}
#https://github.com/Azure/AKS/issues/2907#issuecomment-1109759262
resource "helm_release" "nginx_controller" {
  chart      = "ingress-nginx"
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  namespace        = "ingress-ns"
  create_namespace = true

  values = [
    "${file("nginx_ingress_values.yaml")}"
  ]

}

resource "helm_release" "jenkins" {
  chart      = "jenkins"
  name       = "jenkins"
  namespace  = var.namespace
  repository = "https://marketplace.azurecr.io/helm/v1/repo"
  version    = "11.0.9"
  values = [
    "${file("jenkins_values.yaml")}"
  ]
}

resource "kubernetes_ingress_v1" "nginx_ingress" {
  metadata {
    name = "nginx-ingress"
    annotations = {
      "nginx.ingress.kubernetes.io/rewrite-target" = "/$2"
      "nginx.ingress.kubernetes.io/ssl-redirect" = "false"
      "nginx.ingress.kubernetes.io/use-regex" = "true"

    }

    namespace = var.namespace
  }

  spec {
    ingress_class_name = "nginx"
    rule {
      http {
        path {
          backend {
            service {
              name = "jenkins"
              port {
                number = 80
              }
            }
          }

          path = "/jenkins"
          path_type = "Prefix"
        }
      }
    }
  }
  depends_on = [
    helm_release.nginx_controller,
    helm_release.jenkins
  ]
}