variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the Ingress VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "List of public subnet CIDRs for Ingress (3 for HA)"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "webapp_vpc_cidr" {
  description = "CIDR block for the Web App VPC"
  type        = string
  default     = "10.1.0.0/16"
}

variable "webapp_private_subnets" {
  description = "List of private subnet CIDRs for Web App"
  type        = list(string)
  default     = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
}

variable "egress_vpc_cidr" {
  description = "CIDR block for the Secure Egress VPC"
  type        = string
  default     = "10.2.0.0/16"
}

variable "egress_public_subnets" {
  description = "List of public subnet CIDRs for Egress (NAT GW)"
  type        = list(string)
  default     = ["10.2.1.0/24"]
}

variable "egress_private_subnets" {
  description = "List of private subnet CIDRs for Egress (TGW attachment)"
  type        = list(string)
  default     = ["10.2.4.0/24"]
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "access_logs_bucket" {
  description = "S3 bucket for ALB access logs"
  type        = string
  default     = "alb-logs-381492080129-us-east-1"  # Replace with org bucket
}

variable "domain_name" {
  description = "Domain name for ACM certificate"
  type        = string
  default     = "381492080129.realhandsonlabs.net"  # Replace with your domain
}

variable "alb_domain_name" {
  description = "Domain name for ALB (e.g., app.realhandsonlabs.net)"
  type        = string
  default     = "381492080129.realhandsonlabs.net"
}

variable "hosted_zone_id" {
  description = "Route53 hosted zone ID for domain validation"
  type        = string
  default     = "Z1016218186LBOC34SU2L"  # Provide your hosted zone ID
}