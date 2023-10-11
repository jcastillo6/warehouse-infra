variable "namespace" {
  description = "jenkins namespace name"
  type        = string
  default     = "jenkins"
}
variable "kube_config" {
  type    = string
  default = "~/.kube/config"
}