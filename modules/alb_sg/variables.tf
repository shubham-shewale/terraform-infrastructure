variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "tags" {
  description = "Additional tags (org-specific)"
  type        = map(string)
  default     = {}
}