# Lambda Function to Check EKS Cluster Information

This project creates two AWS Lambda functions and schedules them to run periodically using Amazon EventBridge (Scheduler). The first function, GetEKSInfo, retrieves information about EKS clusters, node groups, and add-ons in the specified regions and saves the information as an Excel file in an S3 bucket. The second function, CreateAccessEntry, creates an access entry and associates the AmazonEKSViewPolicy for the specified Lambda role in each EKS cluster.

![Architecture Overview](https://github.com/jas0n1iu/lambda-check-eks-info/blob/main/images/Architecture.png)

## Prerequisites

1.  Ensure that your AWS account has the necessary permissions to create CloudFormation stacks, Lambda functions, EventBridge rules, IAM roles, and other required resources.
2.  Create an S3 bucket to store the Excel file containing the EKS cluster information.
3.  Create a Lambda layer containing the required Python dependencies. You can use the provided `setup-env.sh` script to create the layer and obtain its ARN.
4.  Existing Amazon EKS clusters accross different regions

## Deployment

### 1. Package Lambda codes and layer zip files

Before running the following command to setup envirement, you have to export S3_BUCKET_NAME to store Lambda codes and zip file used to create Lambda layer.

```shell
git clone https://github.com/jas0n1iu/lambda-check-eks-info.git
export S3_BUCKET_NAME=....... # export S3 Bucket Name to store Lambda codes and zip file used to create Lambda layer
./setup-env.sh
```

This script will create the Lambda layer and output its ARN. Make a note of the ARN as it will be required when creating the CloudFormation stack.

### 2. Deploy CloudFormation Stack

[![Launch Stack](https://cdn.rawgit.com/buildkite/cloudformation-launch-stack-button-svg/master/launch-stack.svg)](https://s3.us-west-2.amazonaws.com/examplelabs.net/template/cf-template-lambda.yaml&stackName=EKSClusterInfoStack)  in Default Region for Accessing Public EKS 

[![Launch Stack](https://cdn.rawgit.com/buildkite/cloudformation-launch-stack-button-svg/master/launch-stack.svg)](https://s3.us-west-2.amazonaws.com/examplelabs.net/template/cf-template-lambda-with-code-vpc.yaml&stackName=EKSClusterInfoStack)  in Default Region to Creating Lambda Functions in Private EKS VPC

Or use the provided `cf-template.yml` or 'cf-template-with-code-vpc.yml' CloudFormation template to create the Lambda functions and scheduled events. You can deploy the stack using the AWS CloudFormation console, AWS CLI, or other deployment tools.

During the stack creation process, you will need to provide the following parameters:

*   `S3BucketName`: The name of the S3 bucket where the Excel file will be stored.
*   `AddonController` (optional): A list of additional controllers (other than the default `aws-load-balancer-controller`) to be included in the cluster information. Allowed values are `cluster-autoscaler`, `aws-load-balancer-controller` and more by modiftying the cloudformation template to add other deployments in EKS.
*   `Regions`: A list of AWS regions where the EKS clusters reside.

For creating Lambda Functions in private EKS VPC only：
*   `VpcId`: The VPC ID of private EKS where the Lambda functions should be deployed.
*   `SubnetIds`: The subnet IDs where the Lambda functions should be deployed.

After successful deployment, the CloudFormation stack will create the following resources:

*   `GetEKSInfo`: A Lambda function that retrieves EKS cluster information and saves it as an Excel file in the specified S3 bucket.
*   `CreateAccessEntry`: A Lambda function that creates an access entry and associates the `AmazonEKSViewPolicy` for the specified Lambda role in each EKS cluster.
*   `GetEKSInfoScheduler`: An Amazon EventBridge (Scheduler) rule that triggers the `GetEKSInfo` every Monday at 9:00 AM (Asia/Shanghai time).
*   `CreateAccessEntryScheduler`: An Amazon EventBridge (Scheduler) rule that triggers the `CreateAccessEntry` every Monday at 8:50 AM (Asia/Shanghai time).
*   IAM roles and policies required for the Lambda functions to access the necessary AWS services.

## Output

The `GetEKSInfo` Lambda function will generate an Excel file named `cluster_info_global_YYMMDD_HHMMSS.xlsx` in the specified S3 bucket. The file will contain information about the EKS clusters, node groups, and add-ons in the specified regions.

Outputs Samples:
![Outputs Samples:](https://github.com/jas0n1iu/lambda-check-eks-info/blob/main/images/Outputs.jpg)

## Cleanup

To remove the resources created by this CloudFormation stack, simply delete the stack from the AWS CloudFormation console or using the AWS CLI.
