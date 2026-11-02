#!/bin/bash

# AWS AppSync API Setup Script for IRL Dating App

set -e

REGION="us-east-1"
API_NAME="IRL-Dating-API"
AUTH_TYPE="AMAZON_COGNITO_USER_POOLS"

echo "🚀 Setting up AWS AppSync API..."

# Get Cognito User Pool ID (from existing Amplify setup)
USER_POOL_ID=$(aws cognito-idp list-user-pools --max-results 20 --region $REGION \
  --query "UserPools[?Name=='IRL-UserPool' || contains(Name, 'IRL')].Id | [0]" \
  --output text)

if [ -z "$USER_POOL_ID" ] || [ "$USER_POOL_ID" == "None" ]; then
  echo "⚠️  No Cognito User Pool found. Creating one..."

  # Create User Pool
  USER_POOL_ID=$(aws cognito-idp create-user-pool \
    --pool-name "IRL-UserPool" \
    --region $REGION \
    --policies "PasswordPolicy={MinimumLength=8,RequireUppercase=false,RequireLowercase=false,RequireNumbers=false,RequireSymbols=false}" \
    --auto-verified-attributes email \
    --username-attributes email \
    --schema Name=email,Required=true,Mutable=false \
    --query 'UserPool.Id' \
    --output text)

  echo "✅ Created User Pool: $USER_POOL_ID"

  # Create User Pool Client
  USER_POOL_CLIENT_ID=$(aws cognito-idp create-user-pool-client \
    --user-pool-id $USER_POOL_ID \
    --client-name "IRL-App-Client" \
    --region $REGION \
    --no-generate-secret \
    --query 'UserPoolClient.ClientId' \
    --output text)

  echo "✅ Created User Pool Client: $USER_POOL_CLIENT_ID"
else
  echo "✅ Found existing User Pool: $USER_POOL_ID"
fi

# Create AppSync API
echo "📡 Creating AppSync API..."

API_ID=$(aws appsync create-graphql-api \
  --name "$API_NAME" \
  --authentication-type "$AUTH_TYPE" \
  --user-pool-config "userPoolId=$USER_POOL_ID,awsRegion=$REGION,defaultAction=ALLOW" \
  --region $REGION \
  --query 'graphqlApi.apiId' \
  --output text)

echo "✅ Created AppSync API: $API_ID"

# Wait for API to be active
echo "⏳ Waiting for API to be active..."
aws appsync get-graphql-api --api-id $API_ID --region $REGION --query 'graphqlApi.status' --output text

# Get API URLs
API_URL=$(aws appsync get-graphql-api --api-id $API_ID --region $REGION --query 'graphqlApi.uris.GRAPHQL' --output text)
echo "✅ API URL: $API_URL"

# Upload GraphQL Schema
echo "📄 Uploading GraphQL schema..."

aws appsync start-schema-creation \
  --api-id $API_ID \
  --definition file://schema.graphql \
  --region $REGION

echo "⏳ Waiting for schema creation to complete..."
sleep 10

# Create Data Source for DynamoDB Users table
echo "💾 Creating DynamoDB data source..."

# Get or create IAM role for AppSync
ROLE_ARN=$(aws iam get-role --role-name AppSyncServiceRole --query 'Role.Arn' --output text 2>/dev/null || \
  aws iam create-role \
    --role-name AppSyncServiceRole \
    --assume-role-policy-document '{
      "Version": "2012-10-17",
      "Statement": [{
        "Effect": "Allow",
        "Principal": {"Service": "appsync.amazonaws.com"},
        "Action": "sts:AssumeRole"
      }]
    }' \
    --query 'Role.Arn' \
    --output text)

# Attach DynamoDB policy
aws iam attach-role-policy \
  --role-name AppSyncServiceRole \
  --policy-arn arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess \
  2>/dev/null || true

echo "✅ IAM Role: $ROLE_ARN"

# Create Data Source
aws appsync create-data-source \
  --api-id $API_ID \
  --name "UsersTable" \
  --type "AMAZON_DYNAMODB" \
  --dynamodb-config "tableName=IRL-Users-dev,awsRegion=$REGION" \
  --service-role-arn "$ROLE_ARN" \
  --region $REGION

echo "✅ Data source created"

# Output configuration
echo ""
echo "========================================="
echo "✅ AWS AppSync Setup Complete!"
echo "========================================="
echo "API ID: $API_ID"
echo "API URL: $API_URL"
echo "Region: $REGION"
echo "User Pool ID: $USER_POOL_ID"
echo ""
echo "Next steps:"
echo "1. Update your amplifyconfiguration.json with these values"
echo "2. Install Amplify libraries for GraphQL"
echo "3. Generate GraphQL models from the schema"
echo "========================================="
