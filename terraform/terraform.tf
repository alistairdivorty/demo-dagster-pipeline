terraform {
  required_version = "~> 1.0"

  backend "s3" {
    bucket = "demo-dagster-tf-state"
    key    = "dagster/terraform.tfstate"
    region = "eu-west-2"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.53"
    }
  }
}

provider "aws" {
  region = local.region
}
