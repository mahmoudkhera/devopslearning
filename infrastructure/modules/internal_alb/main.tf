#ALB


resource "aws_lb" "main" {
    name  = "${var.environment}-alb"
    internal =true

    load_balancer_type="application"
    security_groups    = var.security_group_ids
    subnets            = var.internal_alb_subnets
    enable_deletion_protection = false

     tags = {
    Name        = "${var.name}-alb"
    Environment = var.environment
  }
}


resource "aws_lb_target_group" "front" {
  name     = "front-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/health.html"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name        = "${var.name}-tg"
    Environment = var.environment
  }
}

resource "aws_lb_listener" "internal_alb" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.front.arn
  }
}
