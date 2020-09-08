#!/usr/bin/env bash

if [[ -z "$INPUT_AWS_ACCESS_KEY_ID" ]]
then
    echo "AWS_ACCESS_KEY_ID is missing"
    exit 1
fi

if [[ -z "$INPUT_AWS_SECRET_ACCESS_KEY" ]]
then
    echo "AWS_SECRET_ACCESS_KEY is missing"
    env
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


FixedInputServiceName=\""${INPUT_SERVICE_NAME}"\"
echo $FixedInputServiceName


ServiceName=`aws ecs list-services --cluster "${INPUT_CLUSTER_NAME}" | jq '.serviceArns[] | select(. | contains( "'${INPUT_SERVICE_NAME}'" ))' | cut -d "\"" -f 2 `
echo "Service name"
echo $ServiceName

ServiceImages=`aws ecs list-tasks --cluster $INPUT_CLUSTER_NAME --service-name $ServiceName`
ServiceImageCoincidence=`aws ecs list-tasks --cluster $INPUT_CLUSTER_NAME --service-name $ServiceName | jq '.taskArns[] | select(. | contains("'${INPUT_CURRENT_IMAGE}'"))'`

if [ -z "${ServiceImageCoincidence}"] || [ $("${ServiceImages}" | jq '.[] | length' ) != $("${ServiceImageCoincidence}" | jq '.[] | length') ]
then
  echo "Needs Upgrade"
  echo "::set-output name=updated_img::true"
  exit 0
fi
  echo "::set-output name=updated_img::false"
  echo "No needs upgrade"
  exit 0

## First get the ServiceNames
#aws ecs list-services --cluster cluster-pro > result1.txt
#for((i=0; i< $(jq ' .[] | length' result1.txt ); i++))
#do
	#Line=$(cat result1.txt | jq ".serviceArns[$i]")
	#if [[ "$Line" == *"${INPUT_SERVICE_NAME}"* ]]
	#then
	#	Line2=$(echo "$Line" | cut -d "\"" -f 2)
  #		aws ecs list-tasks --cluster ${INPUT_CLUSTER_NAME} --service-name "$Line2" > result2.txt
  #		for((j=0; j < $(jq ' .[] | length' result2.txt ); j++))
  #		do
	#		if [[ "${INPUT_CURRENT_IMAGE}" != $(cat result2.txt | jq ".taskArns[$j]" | cut -d "\"" -f 2) ]]
	#		then
	#			 echo "::set-output name=updated_img::true"
	#			 echo "Needs update"
	#			exit 0
	#		fi
  #		done

  #	fi
#done
#echo "::set-output name=updated_img::false"
#exit 1


