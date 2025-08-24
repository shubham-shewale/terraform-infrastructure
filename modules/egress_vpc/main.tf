resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = merge(
    var.tags,
    {
      Name        = "egress-vpc-${var.environment}"
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
      Name        = "egress-public-subnet-${var.environment}-${count.index + 1}"
      Environment = var.environment
      Terraform   = "true"
    }
  )
}

resource "aws_subnet" "private" {
  count = length(var.private_subnets)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    var.tags,
    {
      Name        = "egress-private-subnet-${var.environment}-${count.index + 1}"
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
      Name        = "egress-igw-${var.environment}"
      Environment = var.environment
      Terraform   = "true"
    }
  )
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(
    var.tags,
    {
      Name        = "egress-public-rt-${var.environment}"
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

# NAT Gateways
resource "aws_eip" "nat" {
  count = length(var.public_subnets)

  domain = "vpc"

  tags = merge(
    var.tags,
    {
      Name        = "nat-eip-${var.environment}-${count.index + 1}"
      Environment = var.environment
      Terraform   = "true"
    }
  )
}

resource "aws_nat_gateway" "main" {
  count = length(var.public_subnets)

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(
    var.tags,
    {
      Name        = "nat-gw-${var.environment}-${count.index + 1}"
      Environment = var.environment
      Terraform   = "true"
    }
  )

  depends_on = [aws_internet_gateway.main]
}

resource "aws_route_table" "private" {
  count = length(var.private_subnets)

  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }

  tags = merge(
    var.tags,
    {
      Name        = "egress-private-rt-${var.environment}-${count.index + 1}"
      Environment = var.environment
      Terraform   = "true"
    }
  )
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnets)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# CIS: VPC flow logs
resource "aws_flow_log" "vpc_flow_log" {
  iam_role_arn    = var.flow_log_role_arn
  log_destination = aws_cloudwatch_log_group.flow_log.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.main.id
}

resource "aws_cloudwatch_log_group" "flow_log" {
  name              = "/aws/vpc/flowlogs/egress-${var.environment}"
  retention_in_days = 90
}