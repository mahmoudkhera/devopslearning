

resource "aws_vpc" "bastion_vpc" {
  cidr_block           = var.bastion_cider

  tags = {
    Name        = "bastion-vpc"
    Environment = var.environment
  }


}


# Public subnet (Bastion)
resource "aws_subnet" "public_bastion_subnet" {
  vpc_id                  = aws_vpc.bastion_vpc.id
  cidr_block              = "10.1.0.0/24"
  map_public_ip_on_launch = true

   tags = {
    Name        = "${var.environment}-bastion-subnet"
    Environment = var.environment
  }
}


resource "aws_internet_gateway" "igw_bastion" {
  vpc_id = aws_vpc.bastion_vpc.id

   tags = {
    Name        = "${var.environment}-bastion-igw"
    Environment = var.environment
  }
}



# Public route table (bastion)
resource "aws_route_table" "rt_bastion" {
  vpc_id = aws_vpc.bastion_vpc.id
}

resource "aws_route" "internet_bastion" {
  route_table_id         = aws_route_table.rt_bastion.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw_bastion.id
}

resource "aws_route_table_association" "bastion" {
  subnet_id      = aws_subnet.public_bastion_subnet.id
  route_table_id = aws_route_table.rt_bastion.id
}




resource "aws_security_group" "bastion_sg" {
  vpc_id = aws_vpc.bastion_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # restrict later
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

   tags = {
    Name        = "${var.environment}-bastion-sg"
    Environment = var.environment
  }
}


resource "aws_instance" "bastion" {
  ami           = "ami-0324bce2436ce02b2" # ubuntu linux
  instance_type = "t3.nano"
  subnet_id     = aws_subnet.public_bastion_subnet.id

  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  key_name               = var.key_name

   tags = {
    Name        = "${var.environment}-bastion-ec2"
    Environment = var.environment
  }
}
