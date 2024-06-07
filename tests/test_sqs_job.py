from dagster import DagsterInstance, Definitions, RunConfig, build_init_resource_context

from dagster_pipeline.assets import test_asset
from dagster_pipeline.configs import SQSMessageConfig
from dagster_pipeline.jobs import process_sqs_message_job
from dagster_pipeline.resources.sqs import SQSResource


class TestSQSJob:
    def test_sqs_job(self):
        with DagsterInstance.ephemeral() as instance:
            context = build_init_resource_context(instance=instance)
            sqs_resource = SQSResource(
                endpoint_url="http://localhost:4566",
                queue_url="http://localhost:4566/000000000000/my-queue",
            )
            sqs_resource.setup_for_execution(context)

            sqs_resource.purge()

            message_body = "test"
            sqs_resource.send_message(message_body)

            messages = sqs_resource.receive_messages(visibility_timeout=0)
            assert len(messages)
            message = messages[0]

            defs = Definitions(
                assets=[test_asset],
                jobs=[process_sqs_message_job],
                resources={"sqs_resource": sqs_resource},
            )
            result = defs.get_job_def("process_sqs_message_job").execute_in_process(
                run_config=RunConfig(
                    {
                        "test_asset": SQSMessageConfig(
                            message_body=message_body,
                            receipt_handle=message["receipt_handle"],
                        )
                    }
                )
            )

            assert result.success
            assert result.output_for_node("test_asset") == message_body
