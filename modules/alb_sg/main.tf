resource "aws_security_group" "alb" {
  name        = "alb-sg-${var.environment}"
  description = "Security group for ALB in ${var.environment}"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP from anywhere (redirect to HTTPS)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP from Web App VPC for target communication"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.webapp_cidr]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "alb-sg-${var.environment}"
    Environment = var.environment
    Terraform   = "true"
  }
}