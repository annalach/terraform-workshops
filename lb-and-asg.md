# 9. Load Balancer & Auto Scaling Group

{% code title="terraform/webserver-cluster/variables.tf" %}
```bash
variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 8080
}

variable "cluster_min_size" {
  description = "Minimum number of EC2 instances in Auto Scaling Group"
  type        = number
  default     = 3
}

variable "cluster_max_size" {
  description = "Maximum number of EC2 instances in Auto Scaling Group"
  type        = number
  default     = 6
}
```
{% endcode %}

{% code title="terraform/webserver-cluster/mainf.tf" %}
```bash
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

data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    "path" = "../vpc/terraform.tfstate"
  }
}

data "terraform_remote_state" "iam" {
  backend = "local"

  config = {
    "path" = "../iam/terraform.tfstate"
  }
}

data "terraform_remote_state" "secrets" {
  backend = "local"

  config = {
    "path" = "../secrets/terraform.tfstate"
  }
}

data "terraform_remote_state" "database" {
  backend = "local"

  config = {
    "path" = "../database/terraform.tfstate"
  }
}

data "aws_ami" "node_app" {
  filter {
    name   = "name"
    values = ["node-app-*"]
  }

  owners      = ["self"]
  most_recent = true
}

resource "aws_security_group" "alb" {
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  description = "Security Group for Application Load Balancer"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "webserver" {
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  description = "Security Group for Webserver instances"

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = data.terraform_remote_state.vpc.outputs.public_subnets_cidr_blocks
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_configuration" "webserver" {
  image_id             = data.aws_ami.node_app.id
  instance_type        = "t2.micro"
  iam_instance_profile = data.terraform_remote_state.iam.outputs.ec2_instance_profile_name
  security_groups      = [aws_security_group.webserver.id]
  user_data = templatefile(
    "./user_data.sh",
    {
      port          = var.server_port,
      db_secert_arn = data.terraform_remote_state.secrets.outputs.db_secert_arn,
      db_endpoint   = data.terraform_remote_state.database.outputs.endpoint
    }
  )

  lifecycle {
    # reference used in ASG launch confuguraiton will be updated after creating a new resource and destroying this one
    create_before_destroy = true
  }
}

resource "aws_lb_target_group" "asg" {
  name     = "webserver-cluster"
  port     = var.server_port
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.vpc.outputs.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_autoscaling_group" "asg" {
  # Explicitly depend on the launch configuration's name so each time it's replaced, this ASG is also replaced 
  name = aws_launch_configuration.webserver.name

  launch_configuration = aws_launch_configuration.webserver.name
  vpc_zone_identifier  = data.terraform_remote_state.vpc.outputs.private_subnet_ids

  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "ELB"

  min_size = var.cluster_min_size
  max_size = var.cluster_max_size

  # Wait for at least this many instances to pass health checks before considering the ASG deployment complete
  min_elb_capacity = var.cluster_min_size

  # When replacing this ASG, create the replacement first, and only delete the original after 
  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "TerraformWorkshopsWebserver"
    propagate_at_launch = true
  }
}

resource "aws_lb" "alb" {
  name               = "alb"
  load_balancer_type = "application"
  subnets            = data.terraform_remote_state.vpc.outputs.public_subnets_ids
  security_groups    = [aws_security_group.alb.id]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}

resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
}
```
{% endcode %}

{% code title="terraform/webserver-cluster/user\_data.sh" %}
```bash
#!/bin/bash
su ubuntu -c 'export PORT=${port} SECRET_ID=${db_secert_arn} DB_ENDPOINT=${db_endpoint} && nohup ~/.nvm/versions/node/v16.3.0/bin/node ~/app/index.js &'
```
{% endcode %}

{% code title="terraform/webserver-cluster/outputs.tf" %}
```bash
output "alb_dns_name" {
  value       = aws_lb.alb.dns_name
  description = "The domain name of the load balander"
}
```
{% endcode %}

```bash
$ terraform init
$ terraform apply

Apply complete! Resources: 8 added, 0 changed, 0 destroyed.

Outputs:

alb_dns_name = "alb-1971338966.eu-central-1.elb.amazonaws.com"
```

```bash
$ curl http://alb-1971338966.eu-central-1.elb.amazonaws.com
```

