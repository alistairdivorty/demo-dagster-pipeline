from dagster import DagsterInstance, build_init_resource_context

from dagster_pipeline.resources.sqs import SQSResource


class TestSQSResource:
    def test_sqs_resource(self):
        with DagsterInstance.ephemeral() as instance:
            context = build_init_resource_context(instance=instance)
            resource = SQSResource(
                endpoint_url="http://localhost:4566",
                queue_url="http://localhost:4566/000000000000/my-queue",
            )
            resource.setup_for_execution(context)

            resource.purge()

            message_body = "test"
            resource.send_message(message_body)

            messages = resource.receive_messages()
            assert len(messages)
            message = messages[0]
            assert message_body == message["body"]

            resource.delete_message(message["receipt_handle"])
