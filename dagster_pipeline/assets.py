from dagster import asset, get_dagster_logger

logger = get_dagster_logger()


@asset
def test_asset():
    logger.info("Hello, World!")
