#!/bin/bash

API_ID="hhd5uyiigvfbleyd64wjybgqhm"
REGION="us-east-1"
USER_POOL_ID="us-east-1_7TtWmWL5z"
USER_POOL_CLIENT_ID="5dudrrdq4uvmek08c087ejpc2o"

echo "📋 AWS AppSync Configuration"
echo "=============================="

API_URL=$(aws appsync get-graphql-api --api-id $API_ID --region $REGION --query 'graphqlApi.uris.GRAPHQL' --output text)
echo "API URL: $API_URL"
echo "API ID: $API_ID"
echo "Region: $REGION"
echo "User Pool ID: $USER_POOL_ID"
echo "User Pool Client ID: $USER_POOL_CLIENT_ID"
echo ""

cat > appsync-config.json << CONF
{
  "api": {
    "plugins": {
      "awsAPIPlugin": {
        "IRL": {
          "endpointType": "GraphQL",
          "endpoint": "$API_URL",
          "region": "$REGION",
          "authorizationType": "AMAZON_COGNITO_USER_POOLS"
        }
      }
    }
  },
  "auth": {
    "plugins": {
      "awsCognitoAuthPlugin": {
        "UserAgent": "aws-amplify-cli/0.1.0",
        "Version": "0.1.0",
        "IdentityManager": {
          "Default": {}
        },
        "CredentialsProvider": {
          "CognitoIdentity": {
            "Default": {
              "PoolId": "us-east-1:REPLACE_WITH_IDENTITY_POOL",
              "Region": "$REGION"
            }
          }
        },
        "CognitoUserPool": {
          "Default": {
            "PoolId": "$USER_POOL_ID",
            "AppClientId": "$USER_POOL_CLIENT_ID",
            "Region": "$REGION"
          }
        }
      }
    }
  },
  "storage": {
    "plugins": {
      "awsS3StoragePlugin": {
        "bucket": "irl-dating-app-storage",
        "region": "$REGION",
        "defaultAccessLevel": "guest"
      }
    }
  }
}
CONF

echo "✅ Configuration saved to appsync-config.json"
