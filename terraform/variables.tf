variable "aws_region" {
  description = "AWS region to deploy to"
  type        = string
  default     = "eu-north-1"
}

variable "aws_ecs_task_definitionArn" {
  description = "arn of existing task revision"
  type = string
  default = "arn:aws:ecs:eu-north-1:762233768038:task-definition/aws-node-app-task-family:2"
}

variable desired_count {
  description = "Desired number of containers"
  type = number
  default = 1
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "aws-node-app"
}

variable "cluster_name" {
    description = "ECS cluster name"
    type = string
    default = "guide-to-compose-ecs"
}

variable "service_name" {
    description = "ECS service name"
    type = string
    default = "aws-node-app-service"
}


variable "container_image" {
  description = "Container image URI"
  type        = string
  default     = "762233768038.dkr.ecr.eu-north-1.amazonaws.com/akjmto/aws-node-app"
}

variable "container_port" {
  description = "Port exposed by the container"
  type        = number
  default     = 80
}

variable "availability_zones" {
  type = list(string)

  default = [ "eu-north-1a", "eu-north-1b" ]
}

variable "vpc_name" {
  description = "tag name of vpc"
  type = string
  default = "aws-node-app-vpc"
}

variable "alb_name" {
  description = "load balancer"
  type = string
  default = "aws-node-app-load-balancer"
}

variable "repo_name" {
  description = "load balancer"
  type = string
  default = "akjmto/aws-node-app"
}

variable "task_def_family_name" {
  description = "task_def_family_name"
  type = string
  default = "aws-node-app-task-def-family"
}

variable "container_name" {
  description = "deploy.yaml CONTAINER_NAME"
  type = string
  default = "aws-node-app"
}

variable "tg_name" {
  description = "load balancer aws_node_app_lb_target_group"
  type = string
  default = "aws-node-app-tg"
}

variable "ecs_task_execution_role_name" {
  description = "load balancer aws_node_app_lb_target_group"
  type = string
  default = "aws-node-app-ecs-task-execution-role"
}
