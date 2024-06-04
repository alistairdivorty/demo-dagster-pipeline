FROM python:3.10-slim as base

RUN pip install dagster-postgres

ENV DAGSTER_HOME=/opt/dagster/dagster_home/

WORKDIR ${DAGSTER_HOME}

# Copy Dagster instance and workspace YAML files to $DAGSTER_HOME
COPY dagster.yaml workspace.yaml ./

FROM base as dagster_daemon

RUN pip install dagster

FROM base as dagster_webserver

RUN pip install dagster-webserver

FROM base as user_code_grpc

RUN pip install poetry
RUN poetry config virtualenvs.create false

WORKDIR /opt/dagster/app

# Copy in user code package
COPY pyproject.toml poetry.lock ./
COPY dagster_pipeline ./dagster_pipeline

# Install user code package
RUN poetry install --without dev --no-interaction --no-ansi
