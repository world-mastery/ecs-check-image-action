#!/usr/bin/env bash

if [[ -z "$INPUT_AWS_ACCESS_KEY_ID" ]]
then
    echo "AWS_ACCESS_KEY_ID is missing"
    exit 1
fi

if [[ -z "$INPUT_AWS_SECRET_ACCESS_KEY" ]]
then
    echo "AWS_SECRET_ACCESS_KEY is missing"
    exit 1
fi

if [[ -z "$INPUT_AWS_REGION" ]]
then
    echo "AWS_REGION is missing"
    exit 1
fi


if [[ -z "$INPUT_CLUSTER_NAME" ]]
then
    echo "CLUSTER_NAME is missing"
    exit 1
fi

if [[ -z "$INPUT_SERVICE_NAME" ]]
then
    echo "SERVICE_NAME is missing"
    exit 1
fi

if [[ -z "$INPUT_CURRENT_IMAGE" ]]
then
    echo "CURRENT_IMAGE is missing"
    exit 1
fi

## Set AWS credentials
export AWS_ACCESS_KEY_ID="${INPUT_AWS_ACCESS_KEY_ID}"
export AWS_SECRET_ACCESS_KEY="${INPUT_AWS_SECRET_ACCESS_KEY}"
export AWS_DEFAULT_REGION="${INPUT_AWS_REGION}"

ServiceName=`aws ecs list-services --cluster "${INPUT_CLUSTER_NAME}" | jq '.serviceArns[] | select(. | contains( "'${INPUT_SERVICE_NAME}'" ))' | cut -d "\"" -f 2 `
ServiceImageCoincidence=`aws ecs list-tasks --cluster "${INPUT_CLUSTER_NAME}" --service-name "${ServiceName}" | jq '.taskArns[] | select(. | contains( "'${INPUT_CURRENT_IMAGE}'" ) | not)'`
if [ -z "${ServiceImageCoincidence}" ]
then
  echo "::set-output name=updated_img::false"
  echo "No needs upgrade"
  exit 0
fi
  echo "Needs update"
  echo "::set-output name=updated_img::true"
  exit 0


