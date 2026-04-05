


variable "environment" {
  description = "Environment name"
  type        = string
}

variable "bastion_cider" {
  description = "CIDR block for VPC"
  type        = string

  default ="10.1.0.0/16"
}
variable "key_name" {
  description = "SSH key pair name"
  type        = string
}


