import os

from dagster import Definitions
from dagster_aws.s3 import S3PickleIOManager, S3Resource

from dagster_pipeline.assets import test_asset
from dagster_pipeline.jobs import process_sqs_message_job
from dagster_pipeline.resources.sqs import SQSResource
from dagster_pipeline.sensors import process_sqs_message_sensor

defs = Definitions(
    resources={
        "sqs_resource": SQSResource(
            endpoint_url=os.getenv("SQS_QUEUE_ENDPOINT_URL"),
            queue_url=os.getenv("SQS_QUEUE_URL"),
        ),
        "io_manager": S3PickleIOManager(
            s3_resource=S3Resource(endpoint_url=os.getenv("S3_BUCKET_ENDPOINT_URL")),
            s3_bucket=os.getenv("S3_BUCKET_NAME"),
        ),
    },
    assets=[test_asset],
    jobs=[process_sqs_message_job],
    sensors=[process_sqs_message_sensor],
)
