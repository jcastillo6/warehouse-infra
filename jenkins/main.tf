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

resource "helm_release" "jenkins" {
  chart      = "jenkins"
  name       = "jenkins"
  namespace  = var.namespace
  repository = "https://charts.jenkins.io"
  values     = [
    "${file("jenkins_values.yaml")}"
  ]
}

# Ingress for Jenkins
resource "kubernetes_ingress_v1" "jenkins_ingress" {
  wait_for_load_balancer = true
  metadata {
    name      = "jenkins-ingress"
    namespace = var.namespace
    annotations = {
      "nginx.ingress.kubernetes.io/rewrite-target" = "/jenkins"
      "nginx.ingress.kubernetes.io/ssl-redirect" = "false"
      "nginx.ingress.kubernetes.io/use-regex" = "true"
    }
  }

  spec {
    ingress_class_name = "nginx"
    rule {
      http {
        path {
          path = "/jenkins"
          path_type = "Prefix"
          backend {
            service {
              name = "jenkins"
              port {
                number = 8080
              }
            }
          }
        }
      }
    }
  }
}

# Display load balancer IP (typically present in GCP, or using Nginx ingress controller)
output "jenkins_url" {
  value = "${kubernetes_ingress_v1.jenkins_ingress.status.0.load_balancer.0.ingress.0.ip}/jenkins/"
}