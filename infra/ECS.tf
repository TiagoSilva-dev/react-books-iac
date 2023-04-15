module "ecs" {
  source       = "terraform-aws-modules/ecs/aws"
  cluster_name = var.ambiente

  default_capacity_provider_use_fargate = true

  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
  }
}


resource "aws_ecs_task_definition" "projeto" {
  family                   = "projeto"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.cargo.arn

  container_definitions = jsonencode(
    [
      {
        "name"      = "frontend"
        "image"     = "375994091048.dkr.ecr.us-east-1.amazonaws.com/producao:latest"
        "cpu"       = 256
        "memory"    = 512
        "essential" = true
        "portMappings" = [
          {
            "containerPort" = 3000
            "hostPort"      = 3000
          }
        ]
      }
    ]
  )

}
resource "aws_ecs_task_definition" "projeto-back" {
  family                   = "projeto-back"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.cargo.arn

  container_definitions = jsonencode(
    [
      {
        "name"      = "backend"
        "image"     = "375994091048.dkr.ecr.us-east-1.amazonaws.com/producao-back:latest"
        "cpu"       = 256
        "memory"    = 512
        "essential" = true
        "portMappings" = [
          {
            "containerPort" = 4010
            "hostPort"      = 4010
          }
        ]
      }
    ]
  )

}

resource "aws_ecs_service" "projeto" {
  name            = "projeto"
  cluster         = module.ecs.cluster_id
  task_definition = aws_ecs_task_definition.projeto.arn
  desired_count   = 1

  load_balancer {
    target_group_arn = aws_lb_target_group.projeto.arn
    container_name   = "frontend"
    container_port   = 3000
  }

  network_configuration {
    subnets         = module.vpc.private_subnets
    security_groups = [aws_security_group.privado.id]
  }

  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
  }

}

resource "aws_ecs_service" "projeto-back" {
  name            = "projeto-back"
  cluster         = module.ecs.cluster_id
  task_definition = aws_ecs_task_definition.projeto-back.arn
  desired_count   = 1

  load_balancer {
    target_group_arn = aws_lb_target_group.projeto-back.arn
    container_name   = "backend"
    container_port   = 4010
  }

  network_configuration {
    subnets         = module.vpc.private_subnets
    security_groups = [aws_security_group.privado.id]
  }

  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
  }

}
