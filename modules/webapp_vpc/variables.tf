variable "environment" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "private_subnets" {
  type = list(string)
}

variable "availability_zones" {
  type = list(string)
}

variable "tags" {
  type        = map(string)
  default     = {}
}