# File: logs.tf

resource "aws_cloudwatch_log_group" "aws_node_app" {
  name              = "/ecs/aws-node-app" 
}

resource "aws_cloudwatch_log_stream" "task_log_stream" {
  name           = "task-log-stream"
  log_group_name = aws_cloudwatch_log_group.aws_node_app.name
}

# vpc

resource "aws_vpc" "aws_node_app_vpc" {
  cidr_block = "172.17.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name        = var.vpc_name
  }
  
}

resource "aws_subnet" "private_subnet" {
  count = length(var.availability_zones)
  cidr_block        = cidrsubnet(aws_vpc.aws_node_app_vpc.cidr_block, 8, count.index)
  availability_zone = var.availability_zones[count.index]
  vpc_id            = aws_vpc.aws_node_app_vpc.id
}   

resource "aws_subnet" "public_subnet" {
  count = length(var.availability_zones)
  cidr_block        = cidrsubnet(aws_vpc.aws_node_app_vpc.cidr_block, 8, length(var.availability_zones) + count.index)
  availability_zone = var.availability_zones[count.index]
  vpc_id            = aws_vpc.aws_node_app_vpc.id
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.aws_node_app_vpc.id
}

resource "aws_route" "internet_route" {
  route_table_id         = aws_vpc.aws_node_app_vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway.id
}

resource "aws_eip" "nat_ips" {
  count      = length(var.availability_zones)
  depends_on = [aws_internet_gateway.internet_gateway]
}

resource "aws_nat_gateway" "nat_gateway" {
  count         = length(var.availability_zones)
  subnet_id     = element(aws_subnet.public_subnet.*.id, count.index)
  allocation_id = element(aws_eip.nat_ips.*.id, count.index)
}

resource "aws_route_table" "private_route_table" {
  count  = length(var.availability_zones)
  vpc_id = aws_vpc.aws_node_app_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.nat_gateway.*.id, count.index)
  }
}

resource "aws_route_table_association" "private_association" {
  count          = length(var.availability_zones)
  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
  route_table_id = element(aws_route_table.private_route_table.*.id, count.index)
}

# security.tf

resource "aws_security_group" "lb_security_group" {
  name        = "load-balancer-security-group"
  vpc_id      = aws_vpc.aws_node_app_vpc.id

  ingress {
    protocol    = "tcp"
    from_port   = "80"
    to_port     = "80"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "aws_node_app_security_group" {
  name        = "aws-node-app-security-group"
  vpc_id      = aws_vpc.aws_node_app_vpc.id

  ingress {
    protocol        = "tcp"
    from_port       = "80"
    to_port         = "80"
    security_groups = [aws_security_group.lb_security_group.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "allow_services_connectivity" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.aws_node_app_security_group.id
  security_group_id        = aws_security_group.aws_node_app_security_group.id
}

resource "aws_alb" "aws_node_app_alb" {
  name            = var.alb_name
  subnets         = aws_subnet.public_subnet.*.id
  security_groups = [aws_security_group.lb_security_group.id]

}

resource "aws_lb_target_group" "aws_node_app_lb_target_group" {
  name        = var.tg_name
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.aws_node_app_vpc.id
  target_type = "ip"

  health_check {
    healthy_threshold   = "2"
    interval           = "30"
    protocol           = "HTTP"
    matcher            = "200"
    timeout            = "5"
    path              = "/"
    unhealthy_threshold = "2"
  }

  tags = {
    Name        = var.tg_name
  }
}

resource "aws_lb_listener" "aws_node_app_lb_listener" {
  load_balancer_arn = aws_alb.aws_node_app_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.aws_node_app_lb_target_group.arn
  }
}

# File: iam.tf
resource "aws_iam_role" "ecs_task_execution_role" {
  name = var.ecs_task_execution_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

### ECS

resource "aws_ecs_cluster" "guide_to_compose_ecs" {
  name = var.cluster_name

  tags = {
    Name        = var.cluster_name
  }
}

### Task Defenition ###

resource "aws_ecs_task_definition" "aws_task_defenition" {
    family                   = var.task_def_family_name
    network_mode             = "awsvpc"
    requires_compatibilities = ["FARGATE"]
    cpu                      = 256
    memory                   = 512
    execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

    container_definitions = jsonencode([{
        name  = var.container_name
        image = var.container_image
        essential = true
        portMappings = [{
            containerPort = var.container_port
            protocol      = "tcp"
        }]
        environment = [
        {
            name = "PORT",
            value = "80"
        }
        ],
        logConfiguration = {
            logDriver = "awslogs"
            options = {
                awslogs-group         = aws_cloudwatch_log_group.aws_node_app.name
                awslogs-region        = var.aws_region
                awslogs-stream-prefix = "ecs"

            }
        }
    }])

    runtime_platform {
        operating_system_family = "LINUX"
        cpu_architecture        = "X86_64"
    }
  

    tags = {
        Name        = "${var.app_name}-task"
    }
}

### Service ###

resource "aws_ecs_service" "aws_node_app_service" {
  name            = var.service_name
  cluster         = aws_ecs_cluster.guide_to_compose_ecs.id
  task_definition = aws_ecs_task_definition.aws_task_defenition.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.public_subnet[0].id, aws_subnet.public_subnet[1].id, aws_subnet.private_subnet[0].id, aws_subnet.private_subnet[1].id]
    security_groups = [aws_security_group.aws_node_app_security_group.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.aws_node_app_lb_target_group.arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  depends_on = [aws_lb_listener.aws_node_app_lb_listener]

  tags = {
    Name        = var.service_name
  }
}



