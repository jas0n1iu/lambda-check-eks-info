#!/bin/bash
if ! hash aws 2>/dev/null || ! hash pip3 2>/dev/null; then
    echo "This script requires the AWS cli, and pip3 installed"
    exit 2
fi

S3_BUCKET_NAME=examplelabs.net
LAYER_NAME=python-k8s-layer
PYTHON_VERSION=python3.9

# Create Lambda Layer
python3 -m venv create_layer
source create_layer/bin/activate
pip3 install -r ./function/requirements.txt

mkdir python
cp -r create_layer/lib python/
zip -r layer_content.zip python

aws lambda publish-layer-version --layer-name $LAYER_NAME \
    --zip-file fileb://layer_content.zip \
    --compatible-runtimes $PYTHON_VERSION \
    --compatible-architectures "x86_64"

rm -rf create_layer python

cd function
zip -r lambda-access-eks.zip lambda-access-eks.py
zip -r create-access-entry.zip create-access-entry.py

aws s3 cp lambda-access-eks.zip s3://$S3_BUCKET_NAME/code/lambda-access-eks.zip
aws s3 cp create-access-entry.zip s3://$S3_BUCKET_NAME/code/create-access-entry.zip

rm -rf lambda-access-eks.zip create-access-entry.zip

cd ..
aws s3 cp cf-template.yml s3://$S3_BUCKET_NAME/template/cf-template.yml

# Get Lambda Layer ARN
export LAYER_ARN=$(aws lambda list-layer-versions --layer-name $LAYER_NAME --query 'LayerVersions[0].LayerVersionArn' --output text)
echo "Amazon S3 URL: https://s3.$AWS_REGION.amazonaws.com/$S3_BUCKET_NAME/template/cf-template.yml"
echo "LayerArn: $LAYER_ARN"
echo "S3BucketName: $S3_BUCKET_NAME"