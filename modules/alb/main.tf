# modules/alb/main.tf

resource "aws_lb" "web" {
  name               = "web-alb-${var.environment}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.security_groups
  subnets            = var.public_subnets

  enable_deletion_protection = true  # CIS benchmark

  access_logs {
    bucket  = var.access_logs_bucket  # Assume bucket exists; make variable org-specific
    enabled = true
  }

  tags = merge(
    var.tags,
    {
      Name        = "web-alb-${var.environment}"
      Environment = var.environment
      Terraform   = "true"
    }
  )
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.web.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# For HTTPS: Uncomment and provide certificate_arn
# resource "aws_lb_listener" "https" {
#   load_balancer_arn = aws_lb.web.arn
#   port              = 443
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-2016-08"  # Org standard
#   certificate_arn   = var.acm_certificate_arn
#
#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.web.arn
#   }
# }

resource "aws_lb_target_group" "web" {
  name     = "web-tg-${var.environment}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"  # Or 'instance'

  health_check {
    path = "/"
  }

  tags = merge(
    var.tags,
    {
      Environment = var.environment
      Terraform   = "true"
    }
  )
}