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


resource "aws_ecs_task_definition" "front_end" {
  family                   = "front_end"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.cargo.arn
  container_definitions = jsonencode(
    [
      {
        "name"      = "producao"
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
    ]
  )

}


resource "aws_ecs_service" "front_end" {
  name            = "front_end"
  cluster         = module.ecs.cluster_id
  task_definition = aws_ecs_task_definition.front_end.arn
  desired_count   = 1

  load_balancer {
    target_group_arn = aws_lb_target_group.front_end.arn
    container_name   = "producao"
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
