# NAT Instance AMI (using fck-nat - most popular community NAT AMI)
data "aws_ami" "fck_nat" {
  most_recent = true
  owners      = ["568608671756"] # fck-nat official account

  filter {
    name   = "name"
    values = ["fck-nat-al2023-*-arm64-*"]
  }
}

# Security Group for NAT Instance
resource "aws_security_group" "nat" {
  name        = "${var.environment}-nat-sg"
  description = "Security group for NAT instance"
  vpc_id      = var.vpc_id

  # Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow inbound from nginx and front subnets
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = concat(var.nginx_subnets, var.front_subnets)
  }

  tags = {
    Name        = "${var.environment}-nat-sg"
    Environment = var.environment
  }
}

# Elastic IP for NAT Instance
resource "aws_eip" "nat" {
  domain   = "vpc"
  tags = {
    Name        = "${var.environment}-nat-eip"
    Environment = var.environment
  }
}

# NAT Instance (single, in first public subnet)
resource "aws_instance" "nat" {
  ami                         = data.aws_ami.fck_nat.id
  instance_type               = "t4g.nano"   
  subnet_id                   = var.public_subnet_ids[0]
  vpc_security_group_ids      = [aws_security_group.nat.id]
  source_dest_check           = false        # Required for NAT to work
  associate_public_ip_address = true

  tags = {
    Name        = "${var.environment}-nat"
    Environment = var.environment
  }
}

# Attach EIP to NAT Instance
resource "aws_eip_association" "nat" {
  instance_id   = aws_instance.nat.id
  allocation_id = aws_eip.nat.id
}



#  route for nginx route tables
resource "aws_route" "nginx_nat" {
  count                = length(var.nginx_subnets)
  route_table_id       = var.nginx_rt_ids[count.index]
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_instance.nat.primary_network_interface_id
}

#  route for front route tables
resource "aws_route" "front_nat" {
  count                = length(var.front_subnets)
  route_table_id       = var.front_rt_ids[count.index]
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_instance.nat.primary_network_interface_id
}


#  route for front route tables
resource "aws_route" "backend_nat" {
  count                = length(var.backend_subnets)
  route_table_id       = var.backend_rt_ids[count.index]
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_instance.nat.primary_network_interface_id
}





resource "aws_route_table_association" "nginx" {
  count          = length(var.nginx_subnets)
  subnet_id      = var.nginx_subnet_ids[count.index]
  route_table_id = var.nginx_rt_ids[count.index]
}

resource "aws_route_table_association" "front" {
  count          = length(var.front_subnets)
  subnet_id      = var.front_subnet_ids[count.index]
  route_table_id = var.front_rt_ids[count.index]
}

resource "aws_route_table_association" "backend" {
  count          = length(var.backend_subnets)
  subnet_id      = var.backend_subnet_ids[count.index]
  route_table_id = var.backend_rt_ids[count.index]
}