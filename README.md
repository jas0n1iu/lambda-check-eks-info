# Lambda Function to Check EKS Cluster Information

This repo creates two Lambda functions and schedules them to run periodically using Amazon EventBridge (Scheduler). The first function, `GetEKSInfoFunction`, retrieves information about EKS clusters, node groups, and add-ons in the specified regions and saves the information as an Excel file in an S3 bucket. The second function, `CreateAccessEntryFunction`, creates an access entry and associates the `AmazonEKSViewPolicy` for the specified Lambda role in each EKS cluster.

## Prerequisites

1.  Ensure that your AWS account has the necessary permissions to create CloudFormation stacks, Lambda functions, EventBridge rules, IAM roles, and other required resources.
2.  Create an S3 bucket to store the Excel file containing the EKS cluster information.
3.  Create a Lambda layer containing the required Python dependencies. You can use the provided `deploy-lambda-layer.sh` script to create the layer and obtain its ARN.

## Deployment

### 1. Create Lambda Layer

Run the following command to create the Lambda layer:

```shell
git clone https://github.com/jas0n1iu/lambda-check-eks-info.git
./setup-env.sh
```

This script will create the Lambda layer and output its ARN. Make a note of the ARN as it will be required when creating the CloudFormation stack.

### 2. Deploy CloudFormation Stack

Use the provided `cf-template.yml` CloudFormation template to create the Lambda functions and scheduled events. You can deploy the stack using the AWS CloudFormation console, AWS CLI, or other deployment tools.

During the stack creation process, you will need to provide the following parameters:

*   `S3BucketName`: The name of the S3 bucket where the Excel file will be stored.
*   `LayerArn`: The ARN of the Lambda layer containing the Python dependencies, obtained from the previous step.
*   `AddonController` (optional): A list of additional controllers (other than the default `aws-load-balancer-controller`) to be included in the cluster information. Allowed values are `cluster-autoscaler` and `aws-load-balancer-controller`.
*   `Regions`: A list of AWS regions where the EKS clusters reside.

After successful deployment, the CloudFormation stack will create the following resources:

*   `GetEKSInfoFunction`: A Lambda function that retrieves EKS cluster information and saves it as an Excel file in the specified S3 bucket.
*   `CreateAccessEntryFunction`: A Lambda function that creates an access entry and associates the `AmazonEKSViewPolicy` for the specified Lambda role in each EKS cluster.
*   `GetEKSInfoScheduler`: An Amazon EventBridge (Scheduler) rule that triggers the `GetEKSInfoFunction` every Monday at 9:00 AM (Asia/Shanghai time).
*   `CreateAccessEntryScheduler`: An Amazon EventBridge (Scheduler) rule that triggers the `CreateAccessEntryFunction` every Monday at 8:50 AM (Asia/Shanghai time).
*   IAM roles and policies required for the Lambda functions to access the necessary AWS services.

## Output

The `GetEKSInfoFunction` Lambda function will generate an Excel file named `cluster_info_global.xlsx` in the specified S3 bucket. The file will contain information about the EKS clusters, node groups, and add-ons in the specified regions.

## Cleanup

To remove the resources created by this CloudFormation stack, simply delete the stack from the AWS CloudFormation console or using the AWS CLI.
