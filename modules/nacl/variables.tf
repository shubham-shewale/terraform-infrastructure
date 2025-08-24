# modules/nacl/variables.tf

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnets" {
  type = list(string)
}

variable "tags" {
  description = "Additional tags (org-specific)"
  type        = map(string)
  default     = {}
}