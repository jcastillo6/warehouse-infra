provider "kubernetes" {
  config_path = var.kube_config
}

provider "helm" {
  kubernetes {
    config_path = pathexpand(var.kube_config)
  }
}

resource "kubernetes_namespace" "sonar" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "sonar" {
  chart      = "sonarqube"
  name       = "sonarqube"
  namespace  = var.namespace
  repository = "https://sonarSource.github.io/helm-chart-sonarqube"
  values     = [
    "${file("sonar_values.yaml")}"
  ]
}

resource "kubernetes_ingress_v1" "sonar_ingress" {
  wait_for_load_balancer = true
  metadata {
    name      = "sonar-ingress"
    namespace = var.namespace
    annotations = {
      "nginx.ingress.kubernetes.io/rewrite-target" = "/sonar"
      "nginx.ingress.kubernetes.io/ssl-redirect" = "false"
      "nginx.ingress.kubernetes.io/use-regex" = "true"
    }
  }

  spec {
    ingress_class_name = "nginx"
    rule {
      http {
        path {
          path = "/sonar"
          path_type = "Prefix"
          backend {
            service {
              name = "sonarqube-sonarqube"
              port {
                number = 9000
              }
            }
          }
        }
      }
    }
  }
}

# Display load balancer IP (typically present in GCP, or using Nginx ingress controller)
output "sonar_url" {
  value = "${kubernetes_ingress_v1.sonar_ingress.status.0.load_balancer.0.ingress.0.ip}/sonar/"
}