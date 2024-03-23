provider "aws" {
  region = "us-east-2"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_launch_configuration" "launch_asb_configuration" {
  image_id      = "ami-0b8b44ec9a8f90422"
  instance_type = "t2.micro"

  user_data = <<-EOF
        #!/bin/bash
        echo "Hello world to index.html" > index.html
        nohup busybox httpd -f -p ${var.single-cluster-port} &
    EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "cluster-security-group" {
  name = "www-cluster-security-group"

  tags = {
    name = "terraform-maxing"
  }

  ingress {
    from_port   = var.single-cluster-port
    to_port     = var.single-cluster-port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_autoscaling_group" "www-cluster-auto-scaling-group" {
  launch_configuration = aws_launch_configuration.launch_asb_configuration.name
  vpc_zone_identifier  = data.aws_subnets.default.ids
  target_group_arns    = [aws_lb_target_group.target-group.arn]
  health_check_type    = "ELB"

  max_size = 10
  min_size = 2

  tag {
    key                 = "name"
    value               = "terraform-asg-example"
    propagate_at_launch = true
  }
}

resource "aws_lb" "www-cluster-load-balancer" {
  name               = "www-cluster-load-balancer"
  load_balancer_type = "application"
  subnets            = data.aws_subnets.default.ids
  security_groups    = [aws_security_group.load-balancer-security-group.id]
}

resource "aws_lb_listener_rule" "listener-rule" {
  listener_arn = aws_lb_listener.www-cluster-http-listener.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target-group.arn
  }
}

resource "aws_lb_listener" "www-cluster-http-listener" {
  load_balancer_arn = aws_lb.www-cluster-load-balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "NOT FOUND"
      status_code  = 404
    }
  }
}

resource "aws_security_group" "load-balancer-security-group" {
  name = "www-cluster-alb"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_target_group" "target-group" {
  name     = "aws-lb-target-group"
  port     = var.single-cluster-port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
  }
}

variable "single-cluster-port" {
  type        = number
  default     = 8080
  description = "Value of port for security grouping"
}

output "load-balancer-dns" {
  value       = aws_lb.www-cluster-load-balancer.dns_name
  description = "Dns of created load-balancer"
}
