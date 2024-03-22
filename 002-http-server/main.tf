provider "aws" {
    region = "us-east-2"
}

variable "http_security_port" {
    description = "Variable storing port to ingress connection to http-server"
    default = 8080
    type = number
}

resource "aws_instance" "http-server" {
    ami = "ami-0b8b44ec9a8f90422"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.http-server-security-group.id]

    tags = {
        name = "http-server-example"
    }

    user_data_replace_on_change = true
    
    user_data = <<-EOF
        #!/bin/bash
        echo "Hello world to index.html" > index.html
        nohup busybox httpd -f -p ${var.http_security_port} &
    EOF
}

output "public_ip_address" {
    value = aws_instance.http-server
    description = "Public ip-address of created http-server"
}

resource "aws_security_group" "http-server-security-group" {
    name = "http-server-security-group"

    ingress {
        from_port        = var.http_security_port
        to_port          = var.http_security_port
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }
}
