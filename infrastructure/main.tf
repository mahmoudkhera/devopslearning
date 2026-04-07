terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}


#Bastion module
module "bastion" {
  source = "./modules/bastion"
  bastion_cider =var.bastion_cider

  key_name           = var.key_name

   environment     = var.environment

}
# VPC Module
module "vpc" {
  source = "./modules/vpc"

  environment     = var.environment
  vpc_cidr       = var.vpc_cidr
  public_subnets  = var.public_subnets

  internal_alb_subnets=var.internal_alb_subnets
  nginx_subnets = var.nginx_subnets
  front_subnets=var.front_subnets
  azs            = var.availability_zones
}

# Security Module
module "security" {
  source = "./modules/security"

  environment             = var.environment
  vpc_id                 = module.vpc.vpc_id
  allowed_ssh_cidr_blocks = var.allowed_ssh_cidr_blocks
}

resource "aws_vpc_peering_connection" "bastion_to_main" {
  vpc_id        = module.bastion.bastion_id # Bastion VPC
  peer_vpc_id   = module.vpc.vpc_id   # Main VPC
  auto_accept   = true                 # Auto accept if same account

  tags = {
    Name = "bastion-to-main"
  }
}

resource "aws_route" "main_nginx_to_bastion" {
  count                  = length(var.nginx_subnets)
  route_table_id         = module.vpc.nginx_route_table_ids[count.index]
  destination_cidr_block = var.bastion_cider   # Bastion VPC CIDR
  vpc_peering_connection_id = aws_vpc_peering_connection.bastion_to_main.id
}

# Front subnets → Bastion VPC
resource "aws_route" "main_front_to_bastion" {
  count                     = length(var.front_subnets)
  route_table_id            = module.vpc.front_route_table_ids[count.index]
  destination_cidr_block    = var.bastion_cider
  vpc_peering_connection_id = aws_vpc_peering_connection.bastion_to_main.id
}


resource "aws_route" "bastion_to_main" {
  route_table_id         = module.bastion.bastion_route_table
  destination_cidr_block = var.vpc_cidr     # Main VPC CIDR
  vpc_peering_connection_id = aws_vpc_peering_connection.bastion_to_main.id
}




# nat module 
module "nat" {
  source = "./modules/nat_instance"
  environment     = var.environment
  vpc_id=module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  nginx_subnets = var.nginx_subnets
  front_subnets=var.front_subnets
  nginx_subnet_ids=module.vpc.nginx_subnet_ids
  front_subnet_ids=module.vpc.front_subnets_ids
  nginx_rt_ids=module.vpc.nginx_route_table_ids
  front_rt_ids=module.vpc.front_route_table_ids
}



# Application Load Balancer Module
module "alb" {
  source = "./modules/alb"

  environment     = var.environment
  security_group_ids= [module.security.alb_security_group_id]
  vpc_id         = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnet_ids
}

module "internal_alb"{
  source ="./modules/internal_alb"
  environment     = var.environment
  name="internal_alb"
  security_group_ids= [module.security.internal_alb_security_group_id]
  vpc_id         = module.vpc.vpc_id
  internal_alb_subnets = module.vpc.internal_alb_subnets_ids


}



# Auto Scaling Group Module
module "nginx_asg" {
  source = "./modules/asg"

  environment         = var.environment
  name                ="nginx"
  vpc_id             = module.vpc.vpc_id
  user_data_template_path=var.nginx_user_data
  private_subnet_ids = module.vpc.nginx_subnet_ids
  security_group_ids = [module.security.nginx_security_group_id]
  target_group_arns  = [module.alb.target_group_arn]
  instance_type      = var.instance_type
  key_name           = var.key_name
  min_size          = var.asg_min_size
  max_size          = var.asg_max_size
  desired_capacity  = var.asg_desired_capacity
}


# Auto Scaling Group Module
module "front_asg" {
  source = "./modules/asg"

  environment         = var.environment
  name                ="front"
  vpc_id             = module.vpc.vpc_id
  user_data_template_path=var.front_user_data
  private_subnet_ids = module.vpc.front_subnets_ids
  security_group_ids = [module.security.front_security_group_id]
  target_group_arns  = [module.alb.target_group_arn]
  instance_type      = var.instance_type
  key_name           = var.key_name
  min_size          = var.asg_min_size
  max_size          = var.asg_max_size
  desired_capacity  = var.asg_desired_capacity
}