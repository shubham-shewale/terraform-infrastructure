
variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "ingress_cidr" {
  type = string
}

variable "tags" {
  type        = map(string)
  default     = {}
}