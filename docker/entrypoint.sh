#!/usr/bin/env bash

if [[ -z "$AWS_ACCESS_KEY_ID" ]]
then
    echo "AWS_ACCESS_KEY_ID is missing"
    exit 1
fi

if [[ -z "$AWS_SECRET_ACCESS_KEY" ]]
then
    echo "AWS_SECRET_ACCESS_KEY is missing"
    exit 1
fi

if [[ -z "$AWS_DEFAULT_REGION" ]]
then
    echo "AWS_DEFAULT_REGION is missing"
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
echo "The current image is: " ${INPUT_CURRENT_IMAGE}
ServiceName=`aws ecs list-services --cluster "${INPUT_CLUSTER_NAME}" | jq '.serviceArns[] | select(. | contains( "'${INPUT_SERVICE_NAME}'" ))' | cut -d "\"" -f 2 `
echo "The Service Name is: "${ServiceName}
ServiceImages=`aws ecs list-tasks --cluster "${INPUT_CLUSTER_NAME}" --service-name "${ServiceName}"`
echo "The service images are: "${ServiceImages}
ServiceImageCoincidence=`aws ecs list-tasks --cluster "${INPUT_CLUSTER_NAME}" --service-name "${ServiceName}" | jq '.taskArns[] | select(. | contains( "'${INPUT_CURRENT_IMAGE}'" ) | not)'`
echo "The image coincidence is: " ${ServiceImageCoincidence}
if [ -z "${ServiceImageCoincidence}" ]
then
  echo "::set-output name=updated_img::false"
  echo "No needs upgrade"
  exit 0
fi
  echo "Needs update"
  echo "::set-output name=updated_img::true"
  exit 0


