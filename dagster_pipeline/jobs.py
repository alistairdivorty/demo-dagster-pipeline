from dagster import AssetSelection, define_asset_job

process_sqs_message_job = define_asset_job(
    name="process_sqs_message_job",
    selection=AssetSelection.assets("test_asset"),
)
