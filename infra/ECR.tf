resource "aws_ecr_repository" "repositorio" {
  name = var.nome_repositorio
  force_delete = true

}

resource "aws_ecr_repository" "repositorio-back" {
  name = var.nome_repositorio_back
  force_delete = true
}