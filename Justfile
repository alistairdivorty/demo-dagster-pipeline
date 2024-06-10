build:
	docker compose -f docker-compose.yaml up --build

run:
	docker compose -f docker-compose.yaml up

send-message:
	aws sqs send-message \
		--endpoint-url=http://localhost:4566 \
		--queue-url http://localhost:4566/000000000000/my-queue \
		--message-body "test"

push aws-profile:
	#!/usr/bin/env bash
	set -euxo pipefail
	account_id=$(aws sts get-caller-identity --query Account --output text --profile {{aws-profile}})
	aws ecr get-login-password --profile {{aws-profile}} \
		| docker login --username AWS --password-stdin ${account_id}.dkr.ecr.eu-west-2.amazonaws.com
	push () {
		docker tag $1 ${account_id}.dkr.ecr.eu-west-2.amazonaws.com/$1
		docker push ${account_id}.dkr.ecr.eu-west-2.amazonaws.com/$1
	}
	push dagster_daemon
	push dagster_webserver
	push user_code_grpc
