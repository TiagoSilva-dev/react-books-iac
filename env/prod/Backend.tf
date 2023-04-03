terraform {
  backend "s3" {
    bucket     = "terraform-state-projeto-final"
    key        = "Prod/terraform.tfstate"
    region     = "us-west-2"
    access_key = "570438273045"
  }
}
