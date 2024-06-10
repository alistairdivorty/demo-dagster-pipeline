resource "aws_ecs_cluster" "ecs_cluster" {
  name = "dagster"
}

resource "aws_ecs_service" "dagster_daemon" {
  name                   = "dagster_daemon"
  cluster                = aws_ecs_cluster.ecs_cluster.id
  task_definition        = aws_ecs_task_definition.dagster_daemon.arn
  desired_count          = 1
  launch_type            = "FARGATE"
  enable_execute_command = true

  network_configuration {
    subnets          = aws_subnet.private[*].id
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = false
  }

  service_connect_configuration {
    enabled   = true
    namespace = aws_service_discovery_http_namespace.dagster.http_name
  }

  depends_on = [
    aws_ecs_service.user_code_grpc
  ]
}

resource "aws_ecs_service" "dagster_webserver" {
  name                   = "dagster_webserver"
  cluster                = aws_ecs_cluster.ecs_cluster.id
  task_definition        = aws_ecs_task_definition.dagster_webserver.arn
  desired_count          = 1
  launch_type            = "FARGATE"
  enable_execute_command = true

  network_configuration {
    subnets          = aws_subnet.private[*].id
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_tg.arn
    container_name   = "dagster_webserver"
    container_port   = 3000
  }

  service_connect_configuration {
    enabled   = true
    namespace = aws_service_discovery_http_namespace.dagster.http_name

    service {
      port_name      = "http"
      discovery_name = "dagster_webserver"
      client_alias {
        port     = 3000
        dns_name = "dagster_webserver"
      }
    }
  }

  depends_on = [
    aws_ecs_service.user_code_grpc
  ]
}

resource "aws_ecs_service" "user_code_grpc" {
  name                   = "user_code_grpc"
  cluster                = aws_ecs_cluster.ecs_cluster.id
  task_definition        = aws_ecs_task_definition.user_code_grpc.arn
  desired_count          = 1
  launch_type            = "FARGATE"
  enable_execute_command = true

  network_configuration {
    subnets          = aws_subnet.private[*].id
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = false
  }

  service_connect_configuration {
    enabled   = true
    namespace = aws_service_discovery_http_namespace.dagster.http_name

    service {
      port_name      = "grpc"
      discovery_name = "user_code_grpc"
      client_alias {
        port     = 4000
        dns_name = "user_code_grpc.${aws_service_discovery_http_namespace.dagster.http_name}"
      }
    }

    log_configuration {
      log_driver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.service_connect_user_code_grpc.name
        "awslogs-region"        = local.region
        "awslogs-stream-prefix" = "service_connect"
      }
    }
  }
}

resource "aws_ecs_task_definition" "dagster_daemon" {
  family                   = "dagster_daemon"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "2048"
  memory                   = "4096"

  container_definitions = jsonencode([
    {
      name      = "dagster_daemon"
      image     = "${aws_ecr_repository.dagster_daemon.repository_url}:latest"
      essential = true
      command   = ["dagster-daemon", "run"]

      environment = [
        {
          name  = "USER_CODE_GRPC_HOST"
          value = "user_code_grpc.${aws_service_discovery_http_namespace.dagster.http_name}"
        },
        {
          name  = "S3_BUCKET_NAME"
          value = aws_s3_bucket.dagster_bucket.bucket
        },
        {
          name  = "S3_BUCKET_ENDPOINT_URL"
          value = "https://s3.${local.region}.amazonaws.com"
        },
        {
          name  = "SQS_QUEUE_URL"
          value = aws_sqs_queue.dagster_queue.url
        },
        {
          name  = "SQS_QUEUE_ENDPOINT_URL"
          value = "https://sqs.${local.region}.amazonaws.com/${data.aws_caller_identity.current.account_id}/${aws_sqs_queue.dagster_queue.name}"
        },
        {
          name  = "DAGSTER_POSTGRES_HOSTNAME"
          value = aws_rds_cluster.aurora.endpoint
        },
        {
          name  = "DAGSTER_POSTGRES_USER"
          value = local.dagster_postgres_user
        },
        {
          name  = "DAGSTER_POSTGRES_PASSWORD"
          value = local.dagster_postgres_password
        },
        {
          name  = "DAGSTER_POSTGRES_DB"
          value = local.dagster_postgres_db
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.dagster_daemon.name,
          awslogs-region        = local.region
          awslogs-stream-prefix = "ecs_dagster"
        }
      }
    }
  ])

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_execution_role.arn
}

resource "aws_ecs_task_definition" "dagster_webserver" {
  family                   = "dagster_webserver"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "2048"
  memory                   = "4096"

  container_definitions = jsonencode([
    {
      name      = "dagster_webserver"
      image     = "${aws_ecr_repository.dagster_webserver.repository_url}:latest"
      essential = true

      command = [
        "dagster-webserver",
        "-h",
        "0.0.0.0",
        "-p",
        "3000",
        "-w",
        "workspace.yaml"
      ]

      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
          name          = "http"
        }
      ]

      environment = [
        {
          name  = "USER_CODE_GRPC_HOST"
          value = "user_code_grpc.${aws_service_discovery_http_namespace.dagster.http_name}"
        },
        {
          name  = "S3_BUCKET_NAME"
          value = aws_s3_bucket.dagster_bucket.bucket
        },
        {
          name  = "S3_BUCKET_ENDPOINT_URL"
          value = "https://s3.${local.region}.amazonaws.com"
        },
        {
          name  = "SQS_QUEUE_URL"
          value = aws_sqs_queue.dagster_queue.url
        },
        {
          name  = "SQS_QUEUE_ENDPOINT_URL"
          value = "https://sqs.${local.region}.amazonaws.com/${data.aws_caller_identity.current.account_id}/${aws_sqs_queue.dagster_queue.name}"
        },
        {
          name  = "DAGSTER_POSTGRES_HOSTNAME"
          value = aws_rds_cluster.aurora.endpoint
        },
        {
          name  = "DAGSTER_POSTGRES_USER"
          value = local.dagster_postgres_user
        },
        {
          name  = "DAGSTER_POSTGRES_PASSWORD"
          value = local.dagster_postgres_password
        },
        {
          name  = "DAGSTER_POSTGRES_DB"
          value = local.dagster_postgres_db
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.dagster_webserver.name,
          awslogs-region        = local.region
          awslogs-stream-prefix = "ecs_dagster"
        }
      }
    }
  ])

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_execution_role.arn
}

resource "aws_ecs_task_definition" "user_code_grpc" {
  family                   = "user_code_grpc"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "2048"
  memory                   = "4096"

  container_definitions = jsonencode([
    {
      name      = "user_code_grpc"
      image     = "${aws_ecr_repository.user_code_grpc.repository_url}:latest"
      essential = true
      command = [
        "dagster",
        "api",
        "grpc",
        "-m",
        "dagster_pipeline",
        "-h",
        "0.0.0.0",
        "-p",
        "4000"
      ],
      portMappings = [
        {
          containerPort = 4000
          hostPort      = 4000
          name          = "grpc"
        }
      ]
      environment = [
        {
          name  = "S3_BUCKET_NAME"
          value = aws_s3_bucket.dagster_bucket.bucket
        },
        {
          name  = "S3_BUCKET_ENDPOINT_URL"
          value = "https://s3.${local.region}.amazonaws.com"
        },
        {
          name  = "SQS_QUEUE_URL"
          value = aws_sqs_queue.dagster_queue.url
        },
        {
          name  = "SQS_QUEUE_ENDPOINT_URL"
          value = "https://sqs.${local.region}.amazonaws.com/${data.aws_caller_identity.current.account_id}/${aws_sqs_queue.dagster_queue.name}"
        },
        {
          name  = "DAGSTER_POSTGRES_HOSTNAME"
          value = aws_rds_cluster.aurora.endpoint
        },
        {
          name  = "DAGSTER_POSTGRES_USER"
          value = local.dagster_postgres_user
        },
        {
          name  = "DAGSTER_POSTGRES_PASSWORD"
          value = local.dagster_postgres_password
        },
        {
          name  = "DAGSTER_POSTGRES_DB"
          value = local.dagster_postgres_db
        }
      ],
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.user_code_grpc.name,
          awslogs-region        = local.region
          awslogs-stream-prefix = "ecs_dagster"
        }
      }
    }
  ])

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_execution_role.arn
}
