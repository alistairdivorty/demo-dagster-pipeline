build:
	docker compose -f docker-compose.yaml up --build

run:
	docker compose -f docker-compose.yaml up

send-message:
	aws sqs send-message \
	--endpoint-url=http://localhost:4566 \
	--queue-url http://localhost:4566/000000000000/my-queue \
	--message-body "test"
