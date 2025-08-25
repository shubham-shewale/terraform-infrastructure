
variable "environment" {
  type = string
}

variable "subnets" {
  type = list(string)
}

variable "security_groups" {
  type = list(string)
}

variable "tags" {
  type        = map(string)
  default     = {}
}
variable "iam_instance_profile" {
  description = "IAM instance profile name for SSM access"
  type        = string
  default     = null
}