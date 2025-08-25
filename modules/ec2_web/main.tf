
data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  owners = ["137112412989"]  # Amazon
}

resource "aws_instance" "web" {
  count = length(var.subnets)

  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  subnet_id              = var.subnets[count.index]
  vpc_security_group_ids = var.security_groups
  iam_instance_profile   = var.iam_instance_profile

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    INSTANCE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
    echo "<h1>Hello from $INSTANCE_IP</h1>" > /var/www/html/index.html
  EOF

  tags = merge(
    var.tags,
    {
      Name        = "web-ec2-${var.environment}-${count.index + 1}"
      Environment = var.environment
      Terraform   = "true"
    }
  )
}