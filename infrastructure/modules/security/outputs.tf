output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb.id
}

output "nginx_security_group_id" {
  description = "ID of the application security group"
  value       = aws_security_group.nginx.id
}


output "internal_alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.internal_alb.id
}


output "front_security_group_id" {
  description = "ID of the application security group"
  value       = aws_security_group.front.id
}

output "backend_security_group_id" {
  description = "ID of the application security group"
  value       = aws_security_group.backend.id
}


