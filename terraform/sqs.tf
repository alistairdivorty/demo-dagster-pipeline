resource "aws_sqs_queue" "dagster_queue" {
  name = "dagster-queue"
}
