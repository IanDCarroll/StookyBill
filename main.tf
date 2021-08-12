terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 2.13.0"
    }
    # aws = {
    #   source  = "hashicorp/aws"
    #   version = "~> 3.27"
    # }
  }
  required_version = ">= 0.14.9"
}

provider "docker" {}

# provider "aws" {
#   profile = "default"
#   region  = "us-west-2"
# }

# resource "aws_instance" "rtmp_server" {
#   ami           = "ami-830c94e3"
#   instance_type = "t2.micro"

#   tags = {
#     Name = "RTMPServerInstance"
#   }
# }

resource "docker_image" "nginx-rtmp" {
  name         = "tiangolo/nginx-rtmp:latest"
  keep_locally = false
}

resource "docker_container" "nginx-rtmp" {
  image = docker_image.nginx-rtmp.latest
  name  = "stooky_bill"
  ports {
    internal = 1935
    external = 1935
  }
}