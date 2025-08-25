module "vpc" {
  source = "./modules/vpc"

  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  public_subnets     = var.public_subnets
  availability_zones = var.availability_zones
  flow_log_role_arn  = aws_iam_role.flow_log_role.arn
}

module "webapp_vpc" {
  source = "./modules/webapp_vpc"

  environment        = var.environment
  vpc_cidr           = var.webapp_vpc_cidr
  private_subnets    = var.webapp_private_subnets
  availability_zones = var.availability_zones
  flow_log_role_arn  = aws_iam_role.flow_log_role.arn
}

module "egress_vpc" {
  source = "./modules/egress_vpc"

  environment        = var.environment
  vpc_cidr           = var.egress_vpc_cidr
  public_subnets     = var.egress_public_subnets
  private_subnets    = var.egress_private_subnets
  availability_zones = var.availability_zones
  flow_log_role_arn  = aws_iam_role.flow_log_role.arn
}

module "alb_sg" {
  source = "./modules/alb_sg"

  environment   = var.environment
  vpc_id        = module.vpc.vpc_id
  webapp_cidr   = var.webapp_vpc_cidr
}

module "web_sg" {
  source = "./modules/web_sg"

  environment   = var.environment
  vpc_id        = module.webapp_vpc.vpc_id
  ingress_cidr  = var.vpc_cidr
}

module "nacl" {
  source = "./modules/nacl"

  environment    = var.environment
  vpc_id         = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnets
}

module "alb" {
  source = "./modules/alb"

  environment         = var.environment
  vpc_id              = module.vpc.vpc_id
  public_subnets      = module.vpc.public_subnets
  security_groups     = [module.alb_sg.security_group_id]
  access_logs_bucket  = var.access_logs_bucket
  certificate_arn     = aws_acm_certificate_validation.main.certificate_arn
}

module "ec2_web" {
  source = "./modules/ec2_web"

  environment     = var.environment
  subnets         = module.webapp_vpc.private_subnets
  security_groups = [module.web_sg.security_group_id]
  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name
}

# Single IAM Role for VPC Flow Logs
resource "aws_iam_role" "flow_log_role" {
  name = "vpc-flow-log-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "vpc-flow-log-role-${var.environment}"
    Environment = var.environment
    Terraform   = "true"
  }
}

resource "aws_iam_role_policy" "flow_log_policy" {
  role = aws_iam_role.flow_log_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# IAM Role and Policy for SSM
resource "aws_iam_role" "ssm_role" {
  name = "ssm-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "ssm-role-${var.environment}"
    Environment = var.environment
    Terraform   = "true"
  }
}

resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "ssm-profile-${var.environment}"
  role = aws_iam_role.ssm_role.name
}

# VPC Endpoint for SSM
resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = module.webapp_vpc.vpc_id
  service_name      = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type = "Interface"
  security_group_ids = [module.web_sg.security_group_id]
  subnet_ids        = module.webapp_vpc.private_subnets
  private_dns_enabled = true

  tags = {
    Name        = "ssm-endpoint-${var.environment}"
    Environment = var.environment
    Terraform   = "true"
  }
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id            = module.webapp_vpc.vpc_id
  service_name      = "com.amazonaws.${var.region}.ssmmessages"
  vpc_endpoint_type = "Interface"
  security_group_ids = [module.web_sg.security_group_id]
  subnet_ids        = module.webapp_vpc.private_subnets
  private_dns_enabled = true

  tags = {
    Name        = "ssmmessages-endpoint-${var.environment}"
    Environment = var.environment
    Terraform   = "true"
  }
}

resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id            = module.webapp_vpc.vpc_id
  service_name      = "com.amazonaws.${var.region}.ec2messages"
  vpc_endpoint_type = "Interface"
  security_group_ids = [module.web_sg.security_group_id]
  subnet_ids        = module.webapp_vpc.private_subnets
  private_dns_enabled = true

  tags = {
    Name        = "ec2messages-endpoint-${var.environment}"
    Environment = var.environment
    Terraform   = "true"
  }
}

# Transit Gateway
resource "aws_ec2_transit_gateway" "main" {
  description                     = "Transit Gateway for VPC interconnect"
  auto_accept_shared_attachments  = "disable"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"

  tags = {
    Name        = "tgw-${var.environment}"
    Environment = var.environment
    Terraform   = "true"
  }
}

resource "aws_ec2_transit_gateway_route_table" "main" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id

  tags = {
    Name        = "tgw-rt-${var.environment}"
    Environment = var.environment
    Terraform   = "true"
  }

  depends_on = [aws_ec2_transit_gateway.main]
}

# TGW Attachments
resource "aws_ec2_transit_gateway_vpc_attachment" "ingress" {
  subnet_ids         = module.vpc.public_subnets
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = module.vpc.vpc_id

  tags = {
    Name        = "tgw-attach-ingress-${var.environment}"
    Environment = var.environment
    Terraform   = "true"
  }

  depends_on = [module.vpc, aws_ec2_transit_gateway.main]
}

resource "aws_ec2_transit_gateway_vpc_attachment" "webapp" {
  subnet_ids         = module.webapp_vpc.private_subnets
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = module.webapp_vpc.vpc_id

  tags = {
    Name        = "tgw-attach-webapp-${var.environment}"
    Environment = var.environment
    Terraform   = "true"
  }

  depends_on = [module.webapp_vpc, aws_ec2_transit_gateway.main]
}

resource "aws_ec2_transit_gateway_vpc_attachment" "egress" {
  subnet_ids         = module.egress_vpc.private_subnets
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = module.egress_vpc.vpc_id

  tags = {
    Name        = "tgw-attach-egress-${var.environment}"
    Environment = var.environment
    Terraform   = "true"
  }

  depends_on = [module.egress_vpc, aws_ec2_transit_gateway.main]
}

# TGW Route Table Associations
locals {
  attachments = {
    ingress = aws_ec2_transit_gateway_vpc_attachment.ingress.id
    webapp  = aws_ec2_transit_gateway_vpc_attachment.webapp.id
    egress  = aws_ec2_transit_gateway_vpc_attachment.egress.id
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "main" {
  for_each = local.attachments

  transit_gateway_attachment_id  = each.value
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main.id

  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.ingress,
    aws_ec2_transit_gateway_vpc_attachment.webapp,
    aws_ec2_transit_gateway_vpc_attachment.egress,
    aws_ec2_transit_gateway_route_table.main
  ]
}

# TGW Route Table Propagations
resource "aws_ec2_transit_gateway_route_table_propagation" "main" {
  for_each = local.attachments

  transit_gateway_attachment_id  = each.value
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main.id

  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.ingress,
    aws_ec2_transit_gateway_vpc_attachment.webapp,
    aws_ec2_transit_gateway_vpc_attachment.egress,
    aws_ec2_transit_gateway_route_table.main
  ]
}

# TGW Default Route to Egress
resource "aws_ec2_transit_gateway_route" "default" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.egress.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main.id

  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.egress,
    aws_ec2_transit_gateway_route_table.main
  ]
}

# Routes in VPC Route Tables
resource "aws_route" "ingress_default" {
  route_table_id            = module.vpc.public_route_table_id
  destination_cidr_block    = "0.0.0.0/0"
  transit_gateway_id        = aws_ec2_transit_gateway.main.id

  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.ingress,
    aws_ec2_transit_gateway.main,
    module.vpc
  ]
}

resource "aws_route" "webapp_default" {
  route_table_id            = module.webapp_vpc.private_route_table_id
  destination_cidr_block    = "0.0.0.0/0"
  transit_gateway_id        = aws_ec2_transit_gateway.main.id

  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.webapp,
    aws_ec2_transit_gateway.main,
    module.webapp_vpc
  ]
}

resource "aws_route" "egress_public_to_ingress" {
  route_table_id            = module.egress_vpc.public_route_table_id
  destination_cidr_block    = var.vpc_cidr
  transit_gateway_id        = aws_ec2_transit_gateway.main.id

  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.egress,
    aws_ec2_transit_gateway.main,
    module.egress_vpc
  ]
}

resource "aws_route" "egress_public_to_webapp" {
  route_table_id            = module.egress_vpc.public_route_table_id
  destination_cidr_block    = var.webapp_vpc_cidr
  transit_gateway_id        = aws_ec2_transit_gateway.main.id

  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.egress,
    aws_ec2_transit_gateway.main,
    module.egress_vpc
  ]
}

resource "aws_route" "egress_private_to_ingress" {
  count                     = length(var.availability_zones)
  route_table_id            = module.egress_vpc.private_route_table_ids[count.index]
  destination_cidr_block    = var.vpc_cidr
  transit_gateway_id        = aws_ec2_transit_gateway.main.id

  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.egress,
    aws_ec2_transit_gateway.main,
    module.egress_vpc
  ]
}

resource "aws_route" "egress_private_to_webapp" {
  count                     = length(var.availability_zones)
  route_table_id            = module.egress_vpc.private_route_table_ids[count.index]
  destination_cidr_block    = var.webapp_vpc_cidr
  transit_gateway_id        = aws_ec2_transit_gateway.main.id

  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.egress,
    aws_ec2_transit_gateway.main,
    module.egress_vpc
  ]
}

# ALB Target Group Attachments
resource "aws_lb_target_group_attachment" "web" {
  count            = length(var.availability_zones)
  target_group_arn = module.alb.target_group_arn
  target_id        = module.ec2_web.private_ips[count.index]
  port             = 80
  availability_zone = "all"

  depends_on = [
    module.ec2_web,
    module.alb,
    aws_ec2_transit_gateway_vpc_attachment.ingress,
    aws_ec2_transit_gateway_vpc_attachment.webapp,
    aws_ec2_transit_gateway.main
  ]
}

# ACM Certificate for HTTPS
resource "aws_acm_certificate" "main" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  tags = {
    Name        = "alb-cert-${var.environment}"
    Environment = var.environment
    Terraform   = "true"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.main.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.hosted_zone_id

  depends_on = [aws_acm_certificate.main]
}

resource "aws_acm_certificate_validation" "main" {
  certificate_arn         = aws_acm_certificate.main.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
  timeouts {
    create = "5m"
  }

  depends_on = [
    aws_route53_record.cert_validation,
    aws_acm_certificate.main
  ]
}

# Route53 Record for ALB
resource "aws_route53_record" "alb" {
  zone_id = module.alb.zone_id
  name    = var.alb_domain_name
  type    = "A"

  alias {
    name                   = module.alb.dns_name
    zone_id                = module.alb.zone_id
    evaluate_target_health = true
  }

  depends_on = [
    module.alb,
    aws_acm_certificate_validation.main
  ]
}