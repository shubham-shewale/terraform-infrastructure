
resource "aws_security_group" "web" {
  name        = "web-sg-${var.environment}"
  description = "Security group for web EC2 instances"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.ingress_cidr]
    description = "HTTP from Ingress VPC"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound"
  }

  tags = merge(
    var.tags,
    {
      Name        = "web-sg-${var.environment}"
      Environment = var.environment
      Terraform   = "true"
    }
  )
}