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
  private_subnets = var.private_subnets
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

resource "aws_route" "main_private_to_bastion" {
  count                  = length(var.private_subnets)
  route_table_id         = module.vpc.private_route_table_ids[count.index]
  destination_cidr_block = var.bastion_cider   # Bastion VPC CIDR
  vpc_peering_connection_id = aws_vpc_peering_connection.bastion_to_main.id
}


resource "aws_route" "bastion_to_main" {
  route_table_id         = module.bastion.bastion_route_table
  destination_cidr_block = var.vpc_cidr     # Main VPC CIDR
  vpc_peering_connection_id = aws_vpc_peering_connection.bastion_to_main.id
}








# Application Load Balancer Module
module "alb" {
  source = "./modules/alb"

  environment     = var.environment
  security_group_ids= [module.security.alb_security_group_id]
  vpc_id         = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnet_ids
}



# Auto Scaling Group Module
module "asg" {
  source = "./modules/asg"

  environment         = var.environment
  vpc_id             = module.vpc.vpc_id
  user_data_template_path=var.user_data_template_path
  private_subnet_ids = module.vpc.private_subnet_ids
  security_group_ids = [module.security.nginx_security_group_id]
  target_group_arns  = [module.alb.target_group_arn]
  instance_type      = var.instance_type
  key_name           = var.key_name
  min_size          = var.asg_min_size
  max_size          = var.asg_max_size
  desired_capacity  = var.asg_desired_capacity
}