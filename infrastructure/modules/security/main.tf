# Security


#ALB security group

resource "aws_security_group" "alb" {
    name = "${var.environment}-alb-sg"
    description = "security group for application load balancer"
    vpc_id = var.vpc_id


    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

      egress { 
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
   tags = {
    Name        = "${var.environment}-alb-sg"
    Environment = var.environment
  }

}



# nginx  Security Group
resource "aws_security_group" "nginx" {
  name        = "${var.environment}-nginx-sg"
  description = "Security group for application servers"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  

   ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks   =var.allowed_ssh_cidr_blocks
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-nginx-sg"
    Environment = var.environment
  }
}





