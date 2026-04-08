variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
}

variable "nginx_subnets"{
  description ="cider blocks for internal load balancer"
  type  =list(string)
  
}

variable "internal_alb_subnets"{
  description ="cider blocks for internal load balancer"
  type  =list(string)
  
}
variable "front_subnets"{
  description ="cider blocks for internal load balancer"
  type  =list(string)
  
}

variable "backend_subnets"{
  description ="cider blocks for internal load balancer"
  type  =list(string)
}

variable "azs" {
  description = "List of availability zones"
  type        = list(string)
} 

