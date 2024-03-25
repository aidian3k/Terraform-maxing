provider "aws" {
  region = "us-east-2"
}

resource "aws_ami" "this" {
  name = var.user_name
}
