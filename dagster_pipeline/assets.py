from dagster import asset, get_dagster_logger

from dagster_pipeline.configs import SQSMessageConfig
from dagster_pipeline.resources.sqs import SQSResource

logger = get_dagster_logger()


@asset
def test_asset(config: SQSMessageConfig, sqs_resource: SQSResource) -> str:
    logger.info(config.message_body)
    sqs_resource.delete_message(config.receipt_handle)
    return config.message_body
