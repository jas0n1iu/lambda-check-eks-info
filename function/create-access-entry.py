import os
import json
import boto3

regions = os.environ.get('REGIONS').split(',')
lambda_role_arn = os.environ.get('LAMBDA_ROLE_ARN')


def lambda_handler(event, context):
    for region in regions:
        eks_client = boto3.client('eks', region_name=region)

        cluster_names = eks_client.list_clusters()['clusters']
        for cluster_name in cluster_names:
            try:
                # 创建 AWS 身份验证配置映射条目
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

            # 为 Lambda 角色关联 AmazonEKSViewPolicy
            eks_client.associate_access_policy(
                clusterName=cluster_name,
                principalArn=lambda_role_arn,
                policyArn='arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy',
                accessScope={
                    'type': 'namespace',
                    'namespaces': ['kube-system']
                }
            )

    return {
        'statusCode': 200,
        'body': json.dumps('Lambda function executed successfully!')
    }