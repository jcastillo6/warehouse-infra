variable "namespace" {
  description = "sonar namespace name"
  type        = string
  default     = "sonar"
}

variable "kube_config" {
  type    = string
  default = "~/.kube/config"
}