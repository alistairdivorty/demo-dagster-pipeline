locals {
  region = "eu-west-2"
}

locals {
  dagster_postgres_user     = data.aws_secretsmanager_secret_version.dagster_postgres_user.secret_string
  dagster_postgres_password = data.aws_secretsmanager_secret_version.dagster_postgres_password.secret_string
  dagster_postgres_db       = "dagster"
}

