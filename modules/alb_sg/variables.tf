variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "webapp_cidr" {
  type        = string
  description = "CIDR block of the Web App VPC for ALB ingress"
}
variable "tags" {
  description = "Additional tags (org-specific)"
  type        = map(string)
  default     = {}
}