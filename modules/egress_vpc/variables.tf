variable "environment" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnets" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}

variable "availability_zones" {
  type = list(string)
}

variable "flow_log_role_arn" {
  type = string
}

variable "tags" {
  type        = map(string)
  default     = {}
}