
output "private_ips" {
  value = [for inst in aws_instance.web : inst.private_ip]
}