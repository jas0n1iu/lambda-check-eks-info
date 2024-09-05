import os
import json
import boto3

regions = os.environ.get('REGIONS').split(',')
lambda_role_arn = os.environ.get('LAMBDA_ROLE_ARN')
namespace = os.environ.get('NAMESPACE')
policy_arn = os.environ.get('POLICY_ARN')


def lambda_handler(event, context):
    for region in regions:
        eks_client = boto3.client('eks', region_name=region)

        cluster_names = eks_client.list_clusters()['clusters']
        for cluster_name in cluster_names:
            try:
                # Create AWS authentication configuration map entry
                eks_client.create_access_entry(
                    clusterName=cluster_name,
                    principalArn=lambda_role_arn,
                    username='lambda-user',
                    kubernetesGroups=['read-only-group']
                )
                print(f"AccessEntry created for cluster {cluster_name}")
            except eks_client.exceptions.ResourceInUseException:
                print(f"AccessEntry already exists for cluster {cluster_name}")
                continue

            # Associate AmazonEKSViewPolicy with the Lambda role
            eks_client.associate_access_policy(
                clusterName=cluster_name,
                principalArn=lambda_role_arn,
                policyArn=policy_arn,
                accessScope={
                    'type': 'namespace',
                    'namespaces': [namespace]
                }
            )

    return {
        'statusCode': 200,
        'body': json.dumps('Lambda function executed successfully!')
    }