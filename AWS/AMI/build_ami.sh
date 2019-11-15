#!/bin/bash


export PACKER_LOG=1
export PACKER_LOG_PATH=~/logs/packer.log

if [ ! -d ~/logs ]; then
	mkdir ~/logs
fi

usage() {
	echo "export AWS_REGION=\"******\""
	echo "export AWS_ACCESS_KEY=\"***\""
	echo "export AWS_SECRET_KEY=\"***\""
	echo "$0 <target>"
	exit 1
}

if [ -z $1 ]; then
	export TARGET_ENV="sample"
else
	export TARGET_ENV=$1
fi

if [ ! -e src/${TARGET_ENV}.json ]; then
	echo "==> Target file sample.json does not exist"
	usage
	exit 1
fi

if [ -z $AMI_VERSION ]; then
	export AMI_VERSION="0-1-0"
fi

export AMI_NAME="packer-samples-aws-ami-ubuntu18-04-x64-${TARGET_ENV}-v${AMI_VERSION}"

if [ -z $AWS_SECRET_KEY ]; then
	echo "==> Error, define AWS_SECRET_KEY as exported env vars"
	usage
	exit 1
fi

if [ -z $AWS_ACCESS_KEY ]; then
	echo "==> Error, define AWS_ACCESS_KEY as exported env var"
	usage
	exit 1
fi

if [ -z $AWS_REGION ]; then
	echo "==> Error, define AWS_REGION as exported env var"
	usage
	exit 1
fi

# Exported vars expected by Packer:-
export AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY}"
export AWS_SECRET_ACCESS_KEY="${AWS_SECRET_KEY}"
export AWS_DEFAULT_REGION="${AWS_REGION}"

echo "==> Building AMI image: ${AMI_NAME}"

# The args -var can be in src/sample.json also.

packer build \
	-only=amazon-ebs \
	-var ami_name=${AMI_NAME} \
	-var base_ami="ami-0e41581acd7dedd99" \
	-var deploy_enviroment="sample" \
	-var instance_type="t2.large" \
	-var-file=src/${TARGET_ENV}.json \
	ubuntu.json

unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_DEFAULT_REGION
unset AMI_NAME

