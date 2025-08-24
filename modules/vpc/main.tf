resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = merge(
    var.tags,
    {
      Name        = "ingress-vpc-${var.environment}"
      Environment = var.environment
      Terraform   = "true"
    }
  )
}

resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnets[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    var.tags,
    {
      Name        = "public-subnet-${var.environment}-${count.index + 1}"
      Environment = var.environment
      Terraform   = "true"
    }
  )
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name        = "igw-${var.environment}"
      Environment = var.environment
      Terraform   = "true"
    }
  )
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name        = "public-rt-${var.environment}"
      Environment = var.environment
      Terraform   = "true"
    }
  )
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnets)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# CIS: VPC flow logs
resource "aws_flow_log" "vpc_flow_log" {
  iam_role_arn    = var.flow_log_role_arn
  log_destination = aws_cloudwatch_log_group.flow_log.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.main.id
}

resource "aws_cloudwatch_log_group" "flow_log" {
  name              = "/aws/vpc/flowlogs/ingress-${var.environment}"
  retention_in_days = 90
}