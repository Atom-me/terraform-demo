# Internet VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"

  tags = merge(local.common_tags, {
    Name = local.resource_names.vpc
  })
}

# Public Subnet
resource "aws_subnet" "main-public-1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-east-1a"

  tags = merge(local.common_tags, {
    Name = local.resource_names.subnet
  })
}

# Internet Gateway
resource "aws_internet_gateway" "main-gw" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = local.resource_names.internet_gateway
  })
}

# Route table for public subnet
resource "aws_route_table" "main-public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main-gw.id
  }

  tags = merge(local.common_tags, {
    Name = local.resource_names.route_table
  })
}

# Route table association for public subnet
resource "aws_route_table_association" "main-public-1-a" {
  subnet_id      = aws_subnet.main-public-1.id
  route_table_id = aws_route_table.main-public.id
}


