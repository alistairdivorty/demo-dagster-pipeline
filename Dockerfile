FROM python:3.10-slim as base

ENV DAGSTER_HOME=/opt/dagster/dagster_home

ENV VIRTUAL_ENV="${DAGSTER_HOME}/.venv" \
    PATH="${DAGSTER_HOME}/.venv/bin:$PATH"

WORKDIR ${DAGSTER_HOME}

# Copy Dagster instance and workspace YAML files to $DAGSTER_HOME
COPY dagster.yaml workspace.yaml ./

ENV POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_IN_PROJECT=1 \
    POETRY_VIRTUALENVS_CREATE=1

RUN pip install poetry

# Install Dagster dependencies
COPY pyproject.toml poetry.lock ./
RUN poetry install --only dagster --no-interaction --no-ansi --no-root

FROM base as dagster_daemon

ENV DAGSTER_HOME=/opt/dagster/dagster_home

ENV VIRTUAL_ENV="${DAGSTER_HOME}/.venv" \
    PATH="${DAGSTER_HOME}/.venv/bin:$PATH"

COPY --from=base ${VIRTUAL_ENV} ${VIRTUAL_ENV}

FROM base as dagster_webserver

ENV DAGSTER_HOME=/opt/dagster/dagster_home

ENV VIRTUAL_ENV="${DAGSTER_HOME}/.venv" \
    PATH="${DAGSTER_HOME}/.venv/bin:$PATH"

COPY --from=base ${VIRTUAL_ENV} ${VIRTUAL_ENV}

# Install Dagster web server
RUN poetry install --only dagster-webserver --no-interaction --no-ansi --no-root

FROM base as user_code_grpc

WORKDIR /opt/dagster/app

ENV VIRTUAL_ENV="/opt/dagster/dagster_home/.venv"

COPY --from=base ${VIRTUAL_ENV} .

# Copy in user code package
COPY pyproject.toml poetry.lock ./
COPY dagster_pipeline ./dagster_pipeline

# Install user code package
RUN poetry install --without dev --no-interaction --no-ansi
