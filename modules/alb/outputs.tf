
output "alb_dns_name" {
  value = aws_lb.web.dns_name
}

output "target_group_arn" {
  value = aws_lb_target_group.web.arn
}
output "dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.web.dns_name
}

output "zone_id" {
  description = "The zone ID of the load balancer"
  value       = aws_lb.web.zone_id
}