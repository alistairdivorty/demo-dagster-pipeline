resource "aws_cloudwatch_log_group" "dagster_daemon" {
  name              = "/ecs/dagster_daemon"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "dagster_webserver" {
  name              = "/ecs/dagster_webserver"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "user_code_grpc" {
  name              = "/ecs/user_code_grpc"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "service_connect_user_code_grpc" {
  name              = "/ecs/service_connect/user_code_grpc"
  retention_in_days = 30
}
