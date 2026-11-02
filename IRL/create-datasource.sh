#!/bin/bash
set -e

API_ID="hhd5uyiigvfbleyd64wjybgqhm"
REGION="us-east-1"
TABLE_NAME="IRL-Users-dev"

# Create or get IAM role
ROLE_NAME="AppSyncDynamoDBRole"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ROLE_ARN="arn:aws:iam::${ACCOUNT_ID}:role/${ROLE_NAME}"

# Check if role exists
if ! aws iam get-role --role-name $ROLE_NAME 2>/dev/null; then
  echo "Creating IAM role..."
  aws iam create-role \
    --role-name $ROLE_NAME \
    --assume-role-policy-document '{
      "Version": "2012-10-17",
      "Statement": [{
        "Effect": "Allow",
        "Principal": {"Service": "appsync.amazonaws.com"},
        "Action": "sts:AssumeRole"
      }]
    }'
  
  # Attach policy
  aws iam put-role-policy \
    --role-name $ROLE_NAME \
    --policy-name DynamoDBAccess \
    --policy-document '{
      "Version": "2012-10-17",
      "Statement": [{
        "Effect": "Allow",
        "Action": [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ],
        "Resource": "*"
      }]
    }'
  
  sleep 10
fi

echo "✅ IAM Role: $ROLE_ARN"

# Create data source
aws appsync create-data-source \
  --api-id $API_ID \
  --name UsersTable \
  --type AMAZON_DYNAMODB \
  --dynamodb-config "tableName=${TABLE_NAME},awsRegion=${REGION}" \
  --service-role-arn "$ROLE_ARN" \
  --region $REGION 2>/dev/null || echo "Data source already exists"

echo "✅ Data source created"
