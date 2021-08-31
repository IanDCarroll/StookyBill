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
  region  = "us-west-2"
}

resource "aws_ec2_availability_zone_group" "los_angeles" {
  group_name    = "us-west-2-lax-1"
  opt_in_status = "opted-in"
}

# Do I need a route table for this VPC?
resource "aws_vpc" "stookybill_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "stookybill-vpc"
  }
}

resource "aws_internet_gateway" "stookybill_internet_gateway" {
  vpc_id = aws_vpc.stookybill_vpc.id

  tags = {
    Name = "stookybill-igw"
  }
}

variable "local_zone" {
  description = "value"
  type = string
  default = "us-west-2-lax-1a"
}

resource "aws_subnet" "stookybill_transceiver_subnet" {
  vpc_id = aws_vpc.stookybill_vpc.id
  cidr_block = "10.0.0.0/16"
  availability_zone = var.local_zone

  tags = {
    Name = "stookybill-transciever-subnet"
  }
}

resource "aws_ecr_repository" "stookybill_repo" {
  name = "stookybill-repo"

  tags = {
    Name = "stookybill-repo"
  }
}

# Pushing updates to the docker image in the stookybill_repo ECR is a separate concern handled by zsh commands: 
# "tiangolo/nginx-rtmp:latest"
    #     ports:
    #         - "1935:1935"

resource "aws_ecs_cluster" "stookybill_cluster" {
  name = "stookybill-cluster"

  tags = {
    Name = "stookybill-cluster"
  }
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy.json}"
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = "${aws_iam_role.ecsTaskExecutionRole.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_security_group" "public_security_group" {
  vpc_id = aws_vpc.stookybill_vpc.id
  ingress {
    from_port   = var.rtmp_port
    to_port     = var.rtmp_port
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"] # may be the place to allow-list the broadcaster
  }

  egress {
    from_port   = 0 # Allow any incoming port
    to_port     = 0 # Allow any outgoing port
    protocol    = "-1" # Allow any outgoing protocol 
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "public-stookybill-sg"
  }
}

# resource "aws_network_interface" "stookybill_network_interface" {
#   subnet_id   = aws_subnet.stookybill_transceiver_subnet.id
#   private_ips = ["10.0.0.5"]
#   security_groups = [aws_security_group.public_security_group.id]

#   tags = {
#     Name = "stookybill-network-interface"
#   }
# }

variable "rtmp_port" {
  description = "The port that stookybill will be listening and replying"
  type        = number
  default     = 1935 # this is a port above 1024 and does not require root permissions
}

resource "aws_instance" "stookybill_ec2" {
  ami                         = "ami-0671fe8a4329a12ee" # aws ec2 optimized linux (with docker) us-west-2
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.stookybill_transceiver_subnet.id
  availability_zone           = var.local_zone
  vpc_security_group_ids      = ["${aws_security_group.public_security_group.id}"]
  associate_public_ip_address = true # not sure if this is needed or handled by the internet gateway

  user_data = <<-EOF
              #!/bin/bash
              docker pull tiangolo/nginx-rtmp
              docker run -d -p ${var.rtmp_port}:${var.rtmp_port} --name stookybill-docker-container tiangolo/nginx-rtmp
              EOF
  # in theory I could replace this with a git clone and go from there.

  # network_interface {
  #   network_interface_id = aws_network_interface.stookybill_network_interface.id
  #   device_index         = 0
  # }

  tags = {
    Name = "stookybill-ec2"
  }
}

# variable "launch_strategy" {
#   description = "The way ECS will deploy the docker containers"
#   type        = string
#   default     = "EC2" # local zones do not support FARGATE, so we must manually configure this via ec2
# }

# variable "instance_memory" {
#   description = "The RAM to allocate to stookybill"
#   type        = number
#   default     = 512 # MiB
# }

# variable "instance_cpu" {
#   description = "The CPU power to allocate to stookybill"
#   type        = number
#   default     = 256 # GHz?
# }

# # builds / runs nothing unless you've pushed "tiangolo/nginx-rtmp:latest" into ECR
# # and then run aws run-task ...
# resource "aws_ecs_task_definition" "build_run_stookybill_task" {
#   family                   = "build-run-stookybill-task"
#   container_definitions    = <<DEFINITION
#   [
#     {
#       "name": "build-run-stookybill-task",
#       "image": "${aws_ecr_repository.stookybill_repo.repository_url}",
#       "essential": true,
#       "portMappings": [
#         {
#           "containerPort": ${var.rtmp_port},
#           "hostPort": ${var.rtmp_port}
#         }
#       ],
#       "memory": ${var.instance_memory},
#       "cpu": ${var.instance_cpu}
#     }
#   ]
#   DEFINITION
#   placement_constraints {
#     type       = "memberOf"
#     expression = "attribute:ecs.availability-zone in [${var.local_zone}]"
#   }
#   requires_compatibilities = [var.launch_strategy]
#   network_mode             = "awsvpc"
#   memory                   = var.instance_memory
#   cpu                      = var.instance_cpu
#   execution_role_arn       = "${aws_iam_role.ecsTaskExecutionRole.arn}"
# }

# resource "aws_ecs_service" "stookybill_service" {
#   name            = "stookybill-service"
#   cluster         = "${aws_ecs_cluster.stookybill_cluster.id}"
#   task_definition = "${aws_ecs_task_definition.build_run_stookybill_task.arn}"
#   launch_type     = var.launch_strategy
#   desired_count   = 1

#   placement_constraints {
#     type       = "memberOf"
#     expression = "attribute:ecs.availability-zone in [${var.local_zone}]"
#   }

#   network_configuration {
#     subnets          = ["${aws_subnet.stookybill_transceiver_subnet.id}"]
#     assign_public_ip = true
#     security_groups  = ["${aws_security_group.public_security_group.id}"]
#   }

#   tags = {
#     Name = "stookybill-ecs"
#   }
# }

output "public_ip" {
  value = aws_instance.stookybill_ec2.public_ip
  description = "The One IP adress for both sending and recieving video streams"
}

# for when I implement the 2-server model
# resource "aws_security_group" "private_security_group" {
#   vpc_id = aws_vpc.stookybill_vpc.id
#   ingress {
#     from_port = 0
#     to_port   = 0
#     protocol  = "-1"
#     # Only allowing traffic in from the public security group
#     security_groups = ["${aws_security_group.public_security_group.id}"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "private-stookybill-sg"
#   }
# }
