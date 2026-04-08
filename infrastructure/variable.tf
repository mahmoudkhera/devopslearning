variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "eu-west-1"
}

variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
  default     = "dev"
}
variable "name" {
  description = "name of resource in aws"
  type        = string
  default     = "dev"
}
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "192.168.0.0/16"
}

variable "public_subnets" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["192.168.1.0/24", "192.168.2.0/24"]
}



variable "nginx_subnets"{
  description ="cider blocks for internal load balancer"
  type  =list(string)
  default=["192.168.3.0/24", "192.168.4.0/24"]
}

variable "internal_alb_subnets"{
  description ="cider blocks for internal load balancer"
  type  =list(string)
  default=["192.168.5.0/24", "192.168.6.0/24"]
}
variable "front_subnets"{
  description ="cider blocks for internal load balancer"
  type  =list(string)
  default=[ "192.168.7.0/24"]
}

variable "backend_subnets"{
  description ="cider blocks for internal load balancer"
  type  =list(string)
  default=[ "192.168.8.0/24"]
}
variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["eu-west-1a", "eu-west-1b"]
}



variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.nano"
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
  default     = "ec2-key"
}

variable "asg_min_size" {
  description = "Minimum size of the Auto Scaling Group"
  type        = number
  default     = 1
}

variable "asg_max_size" {
  description = "Maximum size of the Auto Scaling Group"
  type        = number
  default     = 2
}

variable "asg_desired_capacity" {
  description = "Desired capacity of the Auto Scaling Group"
  type        = number
  default     = 1
}

variable "allowed_ssh_cidr_blocks" {
  description = "List of CIDR blocks allowed to SSH to bastion host"
  type        = list(string)
  default     = ["10.1.0.0/16"]
} 

variable "bastion_cider" {
  description = "CIDR block for VPC"
  type        = string

  default ="10.1.0.0/16"
}


variable "nginx_user_data" {
  description = "Path to user data template file"
  type        = string
  default = "./templates/nginx_user_data.sh.tpl"
}

variable "nginx_user_data_vars" {
  description = "Variables to pass into user data template"
  type        = map(string)
  default     = {}
}

variable "front_user_data" {
  description = "Path to user data template file"
  type        = string
  default = "./templates/front_user_data.sh.tpl"
}
variable "front_user_data_vars" {
  description = "Variables to pass into user data template"
  type        = map(string)
  default     = {}
}