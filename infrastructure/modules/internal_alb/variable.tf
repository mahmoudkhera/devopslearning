

# Internal  ALB Module

variable "environment" {
  description = "Environment name"
  type        = string
}
variable "name" {
  description = "alb name"
  type        = string
}
variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "internal_alb_subnets"{
  description ="cider blocks for internal load balancer"
  type  =list(string)
  default=["192.168.5.0/24", "192.168.6.0/24"]
}

variable "security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
}


