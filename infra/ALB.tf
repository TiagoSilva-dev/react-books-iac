resource "aws_lb" "projeto" {
  name            = "projeto"
  security_groups = [aws_security_group.alb.id]
  subnets         = module.vpc.public_subnets
}

resource "aws_lb" "projeto-back" {
  name            = "projeto-back"
  security_groups = [aws_security_group.alb.id]
  subnets         = module.vpc.public_subnets
}


resource "aws_lb_target_group" "projeto" {
  name        = "projeto"
  port        = 3000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.vpc.vpc_id

}

resource "aws_lb_listener" "projeto" {
  load_balancer_arn = aws_lb.projeto.arn
  port              = 3000
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.projeto.arn
  }
}

resource "aws_lb_target_group" "projeto-back" {
  name        = "projeto-back"
  port        = 4010
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.vpc.vpc_id

}

resource "aws_lb_listener" "projeto-back" {
  load_balancer_arn = aws_lb.projeto-back.arn
  port              = 4010
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.projeto-back.arn
  }
}


output "IP" {
  value = aws_lb.projeto.dns_name
}

output "IP-BACK" {
  value = aws_lb.projeto-back.dns_name
}
