output "iam_arn" {
  value = aws_ami.this.arn
}

output "mapped_names" {
  value = [for name in var.names : upper(name)]
}