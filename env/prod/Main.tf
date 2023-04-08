module "prod" {
  source = "../../infra"

  nome_repositorio = "producao"
  nome_repositorio_back = "producao-back"
  cargoIAM         = "producao"
  ambiente         = "producao"

}

output "IP_alb" {
  value = module.prod.IP
}

output "IP_alb-back" {
  value = module.prod.IP-BACK
}
