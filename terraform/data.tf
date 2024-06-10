data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {}

data "aws_secretsmanager_secret" "dagster_postgres_user" {
  name = "DAGSTER_POSTGRES_USER"
}

data "aws_secretsmanager_secret_version" "dagster_postgres_user" {
  secret_id = data.aws_secretsmanager_secret.dagster_postgres_user.id
}

data "aws_secretsmanager_secret" "dagster_postgres_password" {
  name = "DAGSTER_POSTGRES_PASSWORD"
}

data "aws_secretsmanager_secret_version" "dagster_postgres_password" {
  secret_id = data.aws_secretsmanager_secret.dagster_postgres_password.id
}
