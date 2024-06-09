from dagster import Config


class SQSMessageConfig(Config):
    message_body: str
    receipt_handle: str
