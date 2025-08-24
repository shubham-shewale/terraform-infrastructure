resource "aws_security_group" "alb" {
  name        = "alb-sg-${var.environment}"
  description = "Security group for ALB handling web traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP from anywhere"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS from anywhere"
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
      Name        = "alb-sg-${var.environment}"
      Environment = var.environment
      Terraform   = "true"
    }
  )
}

# Security best practices: No default rules, least privilege