aws_region = "eu-north-1"
aws_ecs_task_definitionArn = "arn:aws:ecs:eu-north-1:762233768038:task-definition/aws-node-app-task-family:2"
desired_count = 1
app_name = "aws-node-app"
cluster_name = "otmjka-microservices"
service_name = "aws-node-app-service"
container_image = "762233768038.dkr.ecr.eu-north-1.amazonaws.com/akjmto/aws-node-app"
container_port = 80
availability_zones = [ "eu-north-1a", "eu-north-1b" ]
vpc_name = "aws-node-app-vpc"
alb_name = "aws-node-app-load-balancer"
repo_name = "akjmto/aws-node-app"
task_def_family_name = "aws-node-app-task-def-family"
container_name = "aws-node-app"
tg_name = "aws-node-app-tg"
ecs_task_execution_role_name = "aws-node-app-ecs-task-execution-role"