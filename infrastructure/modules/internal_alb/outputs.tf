output "internal_alb_arn" {
  description = "ALB ARN"
  value       = aws_lb.main.arn
}

output "alb_dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.main.dns_name
}

output "front_target_group_arn" {
  description = "Target group ARN"
  value       = aws_lb_target_group.front.arn
}


output "backend_target_group_arn" {
  description = "Target group ARN"
  value       = aws_lb_target_group.backend.arn
}