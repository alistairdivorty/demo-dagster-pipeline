from dagster import Definitions

from dagster_pipeline.assets import test_asset
from dagster_pipeline.jobs import process_sqs_message_job
from dagster_pipeline.resources.sqs import SQSResource
from dagster_pipeline.sensors import process_sqs_message_sensor

defs = Definitions(
    resources={
        "sqs_resource": SQSResource(
            endpoint_url="http://localstack:4566",
            queue_url="http://localstack:4566/000000000000/my-queue",
        )
    },
    assets=[test_asset],
    jobs=[process_sqs_message_job],
    sensors=[process_sqs_message_sensor],
)
