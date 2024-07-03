terraform {
  backend "s3" {
    bucket         = "ogomez-tfstate"
    key            = "terraform.tfstate"
    region         = "eu-south-2"
    skip_region_validation = true
  }
}