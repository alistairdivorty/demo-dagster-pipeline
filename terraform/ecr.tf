resource "aws_ecr_repository" "dagster_daemon" {
  name         = "dagster_daemon"
  force_delete = true
}

resource "aws_ecr_repository" "dagster_webserver" {
  name         = "dagster_webserver"
  force_delete = true
}

resource "aws_ecr_repository" "user_code_grpc" {
  name         = "user_code_grpc"
  force_delete = true
}
