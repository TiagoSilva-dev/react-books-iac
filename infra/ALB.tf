resource "aws_lb" "front_end" {
  name            = "ECS-React"
  security_groups = [aws_security_group.alb.id]
  subnets         = module.vpc.public_subnets
}


resource "aws_lb_target_group" "front_end" {
  name        = "ECS-React"
  port        = 3000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.vpc.vpc_id

}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.front_end.arn
  port              = 3000
  protocol          = "HTTP"
  // ssl_policy        = "ELBSecurityPolicy-2016-08"

  // certificate_arn = "arn:aws:acm:us-west-2:570438273045:certificate/dfd476e6-e1a3-490a-9667-d8cfc3644a67"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.front_end.arn
  }
}

output "IP" {
  value = aws_lb.front_end.dns_name
}
