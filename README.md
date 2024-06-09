# Demo Dagster Pipeline

## Setup

### Install Docker

Install Docker and Docker Compose by following the instructions [here](https://docs.docker.com/get-docker/).

### Install `just`

Install the `just` command runner by following the instructions [here](https://github.com/casey/just?tab=readme-ov-file#installation).

### Install Python (optional)

Install the pyenv Python version manager by following the instructions [here](https://github.com/pyenv/pyenv?tab=readme-ov-file#installation).
Initialize pyenv with the command `pyenv init`.
Install the interpreter for Python version 3.10 with the command `pyenv install 3.10`.
Set the local application-specific Python version to 3.10 with the command `pyenv local 3.10`.

### Install Poetry (optional)

Install the Poetry dependency management tool by following the instructions [here](https://python-poetry.org/docs/#installing-with-the-official-installer).
Tell Poetry which Python version to use for the current project with the command `poetry env use 3.10`.

### Install VS Code Python Extension (optional)

Install the Microsoft [Python extension for Visual Studio Code](https://code.visualstudio.com/docs/languages/python#_install-python-and-the-python-extension).

### Install VS Code Black Extension (optional)

Install the Microsoft [Black Formatter extension for Visual Studio Code](https://marketplace.visualstudio.com/items?itemName=ms-python.black-formatter).

## Quickstart

Run the command `just build` to build Docker images and start services with Docker Compose. The Dagster web server UI will be served from `http://localhost:3000`.

To initiate a job run via the sensor for processing SQS messages run the command `just send-message`.

## Exercises

1. Add an asset with an upstream dependency.
2. Add a job that materializes multiple assets.
3. Add a sensor... (WIP)
