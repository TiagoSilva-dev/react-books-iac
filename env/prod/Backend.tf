terraform {
  backend "s3" {
    bucket     = "terraform-state-projeto-final2"
    key        = "Prod/terraform.tfstate"
    region     = "us-west-2"
    access_key = "554559581131"
  }
}
