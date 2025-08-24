variable "environment" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnets" {
  type = list(string)
}

variable "availability_zones" {
  type = list(string)
}

variable "tags" {
  description = "Additional tags (org-specific)"
  type        = map(string)
  default     = {}
}