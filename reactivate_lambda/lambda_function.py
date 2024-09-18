import boto3

def lambda_handler(event, context):
    iam = boto3.client('iam')
    users = iam.list_users()['Users']
    for user in users:
        access_keys = iam.list_access_keys(UserName=user['UserName'])['AccessKeyMetadata']
        for key in access_keys:
            iam.update_access_key(UserName=user['UserName'], AccessKeyId=key['AccessKeyId'], Status='Active')

