#!/bin/bash
awslocal sqs create-queue --queue-name my-queue --region eu-west-2
awslocal s3api create-bucket --bucket my-bucket