output "vpc_id" {
  value = module.vpc.vpc_id
}

output "webapp_vpc_id" {
  value = module.webapp_vpc.vpc_id
}

output "egress_vpc_id" {
  value = module.egress_vpc.vpc_id
}

output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "public_subnets" {
  value = module.vpc.public_subnets
}