resource "aws_s3_bucket" "dagster_bucket" {
  bucket        = "dagster-bucket-${random_id.bucket_id.hex}"
  force_destroy = true
}

resource "random_id" "bucket_id" {
  byte_length = 8
}
