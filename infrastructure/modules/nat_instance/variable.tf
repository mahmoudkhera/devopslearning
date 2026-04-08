variable "environment" {
  description = "Environment name"
  type        = string
}

variable vpc_id {
  type        = string
  description = "the vpc that has nat instance "
  
}

variable "nginx_subnets"{
  description ="cider blocks for internal load balancer"
  type  =list(string)
  default=["192.168.3.0/24", "192.168.4.0/24"]
}


variable "front_subnets"{
  description ="cider blocks for internal load balancer"
  type  =list(string)
  default=[ "192.168.7.0/24"]
}

variable "backend_subnets"{
  description ="cider blocks for internal load balancer"
  type  =list(string)
}

variable "public_subnets" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["192.168.1.0/24", "192.168.2.0/24"]
}

variable "public_subnet_ids" {
  description = " the public subnet ids"
  type = list(string)
}


variable "nginx_subnet_ids" {
  description = "List of nginx subnet IDs"
  type = list(string)
}

variable "front_subnet_ids" {
  description = "List of nginx subnet IDs"
  type = list(string)
}

variable "backend_subnet_ids" {
  description = "List of nginx subnet IDs"
  type = list(string)
}

variable "nginx_rt_ids" {
  description = " the route table for the nginx subnets "
  type = list(string)
}

variable "front_rt_ids" {
  description = " the route table for the nginx subnets "
  type = list(string)
}

variable "backend_rt_ids" {
  description = " the route table for the nginx subnets "
  type = list(string)
}