from __future__ import annotations

from typing import Any, TypedDict
from uuid import uuid4

import boto3
from dagster import ConfigurableResource
from pydantic import PrivateAttr


class SQSResource(ConfigurableResource):
    endpoint_url: str
    queue_url: str
    _queue: Any = PrivateAttr()

    def setup_for_execution(self, context):
        sqs = boto3.resource("sqs", endpoint_url=self.endpoint_url)
        self._queue = sqs.Queue(self.queue_url)

    def send_message(self, body: str) -> None:
        """Push a message to the queue."""
        self._queue.send_message(MessageBody=body)

    def receive_messages(
        self, max_number_of_messages: int = 1, visibility_timeout: int | None = None
    ) -> list[SQSMessage]:
        """Dequeue messages and return dictionaries containing their ID, body and receipt handle."""
        messages = self._queue.receive_messages(
            MaxNumberOfMessages=max_number_of_messages,
            **(
                dict(VisibilityTimeout=visibility_timeout) if visibility_timeout else {}
            ),
        )
        return [
            SQSMessage(
                id=message.message_id,
                body=message.body,
                receipt_handle=message.receipt_handle,
            )
            for message in messages
        ]

    def delete_message(self, receipt_handle: str):
        """Delete message identified by its receipt handle."""
        response = self._queue.delete_messages(
            Entries=[
                {
                    "Id": str(uuid4()),
                    "ReceiptHandle": receipt_handle,
                }
            ]
        )
        if len(response["Failed"]):
            raise Exception(response["Failed"][0]["Message"])

    def purge(self):
        """Delete all available messages in the queue."""
        self._queue.purge()


class SQSMessage(TypedDict):
    id: str
    body: str
    receipt_handle: str
