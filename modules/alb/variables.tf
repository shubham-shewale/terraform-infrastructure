variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnets" {
  type = list(string)
}

variable "security_groups" {
  type = list(string)
}

variable "access_logs_bucket" {
  description = "S3 bucket for ALB access logs"
  type        = string
  default     = "alb-logs-default"  # Replace with org bucket
}

# variable "acm_certificate_arn" {
#   type = string
# }

variable "tags" {
  description = "Additional tags (org-specific)"
  type        = map(string)
  default     = {}
}