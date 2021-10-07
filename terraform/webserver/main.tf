terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "eu-central-1"
}

resource "aws_instance" "webserver" {
  ami           = "ami-091f21ecba031b39a"
  instance_type = "t2.micro"

  tags = {
    Name = "TerraformWorkshops"
  }
}
