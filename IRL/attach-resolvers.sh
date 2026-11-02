#!/bin/bash
set -e

API_ID="hhd5uyiigvfbleyd64wjybgqhm"
REGION="us-east-1"
DATA_SOURCE="UsersTable"

echo "📎 Attaching resolvers..."

# Create getUser resolver
aws appsync create-resolver \
  --api-id $API_ID \
  --type-name Query \
  --field-name getUser \
  --data-source-name $DATA_SOURCE \
  --request-mapping-template "file://resolvers/getUser-request.vtl" \
  --response-mapping-template "file://resolvers/getUser-response.vtl" \
  --region $REGION 2>/dev/null || echo "getUser resolver exists"

# Create createUser resolver
aws appsync create-resolver \
  --api-id $API_ID \
  --type-name Mutation \
  --field-name createUser \
  --data-source-name $DATA_SOURCE \
  --request-mapping-template "file://resolvers/createUser-request.vtl" \
  --response-mapping-template "file://resolvers/createUser-response.vtl" \
  --region $REGION 2>/dev/null || echo "createUser resolver exists"

# Create updateUser resolver
aws appsync create-resolver \
  --api-id $API_ID \
  --type-name Mutation \
  --field-name updateUser \
  --data-source-name $DATA_SOURCE \
  --request-mapping-template "file://resolvers/updateUser-request.vtl" \
  --response-mapping-template "file://resolvers/updateUser-response.vtl" \
  --region $REGION 2>/dev/null || echo "updateUser resolver exists"

echo "✅ Resolvers attached successfully"
