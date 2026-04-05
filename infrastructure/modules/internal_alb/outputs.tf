output "internal_alb_arn" {
  description = "ALB ARN"
  value       = aws_lb.internal_alb.arn
}

output "alb_dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.internal_alb.dns_name
}

output "target_group_arn" {
  description = "Target group ARN"
  value       = aws_lb_target_group.front.arn
}