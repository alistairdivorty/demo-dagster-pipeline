from typing import Iterator

from dagster import (
    DefaultSensorStatus,
    RunConfig,
    RunRequest,
    SensorEvaluationContext,
    get_dagster_logger,
    sensor,
)

from dagster_pipeline.configs import SQSMessageConfig
from dagster_pipeline.resources.sqs import SQSResource

logger = get_dagster_logger()


@sensor(
    job_name="process_sqs_message_job",
    minimum_interval_seconds=10,
    default_status=DefaultSensorStatus.RUNNING,
)
def process_sqs_message_sensor(
    context: SensorEvaluationContext,
    sqs_resource: SQSResource,
) -> Iterator[RunRequest]:
    messages = sqs_resource.receive_messages(visibility_timeout=300)
    for message in messages:
        yield RunRequest(
            run_key=message["id"],
            run_config=RunConfig(
                {
                    "test_asset": SQSMessageConfig(
                        message_body=message["body"],
                        receipt_handle=message["receipt_handle"],
                    )
                }
            ),
        )
