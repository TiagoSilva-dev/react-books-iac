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
        "name"      = "front_end"
        "image"     = "570438273045.dkr.ecr.us-west-2.amazonaws.com/producao:v1"
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
      ], [
      {
        "name"      = "back_end"
        "image"     = "570438273045.dkr.ecr.us-west-2.amazonaws.com/producao:v1"
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
    container_name   = "projeto"
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
