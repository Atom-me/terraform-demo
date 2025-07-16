resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags       = { Name = "${var.prefix}-vpc" }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  tags                    = { Name = "${var.prefix}-subnet" }
}

# 获取可用区信息
data "aws_availability_zones" "available" {
  state = "available"
}

# 创建路由表
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  
  tags = { Name = "${var.prefix}-public-rt" }
}

# 将子网关联到路由表
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.public.id
}

output "vpc_id" {
  value = aws_vpc.main.id
}
output "subnet_id" {
  value = aws_subnet.main.id
} 