from dagster import Definitions

from dagster_pipeline.assets import test_asset

defs = Definitions(
    assets=[test_asset],
)
