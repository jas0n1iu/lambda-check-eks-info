#!/bin/bash
if ! hash aws 2>/dev/null || ! hash python3 2>/dev/null || ! hash pip3 2>/dev/null; then
    echo "This script requires the AWS cli, and pip3 installed"
    exit 2
fi

# Check if S3_BUCKET_NAME environment variable is set
if [ -z "$S3_BUCKET_NAME" ]; then
    echo "Error: S3_BUCKET_NAME environment variable is not set"
    exit 1
fi

# Package the Python kubernetes & openpyxl library in a layer .zip file
python3 -m venv create_layer
source create_layer/bin/activate
pip3 install -r ./function/requirements.txt

mkdir python
cp -r create_layer/lib python/
zip -r layer_content.zip python

rm -rf create_layer python

aws s3 cp layer_content.zip s3://$S3_BUCKET_NAME/layer/layer_content.zip

cd function
zip -r lambda-access-eks.zip lambda-access-eks.py
zip -r create-access-entry.zip create-access-entry.py

aws s3 cp lambda-access-eks.zip s3://$S3_BUCKET_NAME/code/lambda-access-eks.zip
aws s3 cp create-access-entry.zip s3://$S3_BUCKET_NAME/code/create-access-entry.zip

rm -rf lambda-access-eks.zip create-access-entry.zip
