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
ServiceName=`aws ecs list-services --cluster "${INPUT_CLUSTER_NAME}" | jq '.serviceArns[] | select(. | contains( "'${INPUT_SERVICE_NAME}'" ))' | cut -d "\"" -f 2 `
echo "The service is: "${ServiceName}
ServiceArns=`aws ecs list-tasks --cluster "${INPUT_CLUSTER_NAME}" --service-name "${ServiceName}" | jq -c '.taskArns | join(" ") | gsub("arn:aws:ecs:eu-west-1:145684445275:task/"; "")'`
ServiceArns=`echo "${ServiceArns}" | sed -e 's/^"//' -e 's/"$//'`
echo "The services arns are: "${ServiceArns}
Coincidences=`aws ecs describe-tasks --cluster "${INPUT_CLUSTER_NAME}" --tasks "${ServiceArns}" | jq '.tasks[].containers[].image | select(. | contains( "'${INPUT_CURRENT_IMAGE}'" ) | not )'`
echo "The images that differ from the pushed one are: "${Coincidences}
if [ -z "${Coincidences}" ]
then
  echo "::set-output name=updated_img::false"
  echo "No needs upgrade"
  exit 0
fi
  echo "Needs update"
  echo "::set-output name=updated_img::true"
  exit 0


