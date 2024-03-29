terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.0.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
  alias = "region_1"
}

provider "aws" {
  region = "us-east-1"
  alias = "region_2"
}

data "aws_region" "region_1" {
  provider = aws.region_1
}

data "aws_region" "region_2" {
  provider = aws.region_2
}

data "aws_ami" "aws_ami_region_1" {
  provider = data.aws_region.region_1.name
  most_recent = true
  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.20210813.0-x86_64-gp2"]
  }
}

output "current_region" {
  description = "The current region"
  value = data.aws_region.region_1.name
}

output "second_region_name" {
  value = data.aws_region.region_2.name
}

resource "aws_instance" "region_1_instance" {
  provider = aws.region_1
  ami = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"

  tags = {
    region = data.aws_region.region_1.name
    environment = "dev"
  }
}

resource "aws_instance" "region_2_instance" {
  provider = aws.region_2
  ami = data.aws_ami.aws_ami_region_1.id // better approach as we use the same ami in both regions
  instance_type = "t2.micro"

  tags = {
    region = data.aws_region.region_2.name
    environment = "dev"
  }
}

output "region_1_instance_id" {
  description = "public dns of first instance"
  value = aws_instance.region_1_instance.public_dns
}