provider "aws" {
  region = "us-east-2"
}

variable "user_names" {
  description = "Sample users for iam"
  type = list(string)
  default = ["adrian", "jose", "juan"]
}

resource "aws_ami" "ami_instance" {
  count = 3
  name = "adrian-${count.index}"
}

resource "aws_ami" "ami_using_list" {
  count = length(var.user_names)
  name = var.user_names[count.index]
}

output "first_ami_user_arn" {
  description = "Arn of the first created user in list"
  value = aws_ami.ami_using_list[0].arn
}

module "users" {
  source = "./modules/iam"
  user_name = "adrian"
}

resource "aws_ami" "ami_users_for_each" {
  for_each = toset(var.user_names)
  name = each.value
}

output "mapped_only_arns" {
  description = "Mapping only arns from the created map of iam users"
  value = values(aws_ami.ami_users_for_each)[*].arn
}

output "all_ami_users_arns" {
  description = "Arns of all created users in list"
  value = aws_ami.ami_using_list[*].arn
}