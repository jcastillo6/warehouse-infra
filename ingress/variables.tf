variable "namespace" {
  description = "ingress namespace name"
  type        = string
  default     = "ingress-ns"
}

variable "kube_config" {
  type    = string
  default = "~/.kube/config"
}