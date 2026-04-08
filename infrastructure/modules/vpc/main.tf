# VPC Module

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.environment}-vpc"
    Environment = var.environment
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.environment}-igw"
    Environment = var.environment
  }
}

# Public Subnets
resource "aws_subnet" "public" {
  count             = length(var.public_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnets[count.index]
  availability_zone = var.azs[count.index]

  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.environment}-public-subnet-${count.index + 1}"
    Environment = var.environment
  }
}

resource "aws_subnet" "internal_alb_subnets" {
  count             = length(var.internal_alb_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.internal_alb_subnets[count.index]
  availability_zone = var.azs[count.index]

  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.environment}-interna-alb-subnet-${count.index + 1}"
    Environment = var.environment
  }
}

# Private Subnets
resource "aws_subnet" "nginx_subnets" {
  count             = length(var.nginx_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.nginx_subnets[count.index]
  availability_zone = var.azs[count.index]

  tags = {
    Name        = "${var.environment}-nginx-subnet-${count.index + 1}"
    Environment = var.environment
  }
}


resource "aws_subnet" "front_subnets" {
  count             = length(var.front_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.front_subnets[count.index]
  availability_zone = var.azs[count.index]

  tags = {
    Name        = "${var.environment}-front-subnet-${count.index + 1}"
    Environment = var.environment
  }
}


resource "aws_subnet" "backend_subnets" {
  count             = length(var.backend_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.backend_subnets[count.index]
  availability_zone = var.azs[count.index]

  tags = {
    Name        = "${var.environment}-backend-subnet-${count.index + 1}"
    Environment = var.environment
  }
}

# Elastic IP for NAT Gateway
# resource "aws_eip" "nat" {
#   count = length(var.public_subnets)

#   tags = {
#     Name        = "${var.environment}-nat-eip-${count.index + 1}"
#     Environment = var.environment
#   }
# }

# # NAT Gateway
# resource "aws_nat_gateway" "main" {
#   count         = length(var.public_subnets)
#   allocation_id = aws_eip.nat[count.index].id
#   subnet_id     = aws_subnet.public[count.index].id

#   tags = {
#     Name        = "${var.environment}-nat-${count.index + 1}"
#     Environment = var.environment
#   }
# }

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name        = "${var.environment}-public-rt"
    Environment = var.environment
  }
}

# nginx Route Tables
resource "aws_route_table" "nginx_rt" {
  count  = length(var.nginx_subnets)
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.environment}-nginx-rt-${count.index + 1}"
    Environment = var.environment
  }
}

# nginx Route Tables
resource "aws_route_table" "front_rt" {
  count  = length(var.front_subnets)
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.environment}-front-rt-${count.index + 1}"
    Environment = var.environment
  }
}

resource "aws_route_table" "backend_rt" {
  count  = length(var.backend_subnets)
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.environment}-backend-rt-${count.index + 1}"
    Environment = var.environment
  }
}

# Route Table Associations
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# resource "aws_route_table_association" "nginx" {
#   count          = length(var.nginx_subnets)
#   subnet_id      = aws_subnet.nginx_subnets[count.index].id
#   route_table_id = aws_route_table.nginx_rt[count.index].id
# }

# resource "aws_route_table_association" "front" {
#   count          = length(var.front_subnets)
#   subnet_id      = aws_subnet.front_subnets[count.index].id
#   route_table_id = aws_route_table.front_rt[count.index].id
# }

