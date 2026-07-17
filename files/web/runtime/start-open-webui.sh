#!/bin/bash
set -e

AWS_REGION="$1"
DB_SECRET_ARN="$2"
DB_HOST="$3"
DB_PORT="$4"
DB_NAME="$5"
DNS_NAME="$6"

DB_SECRET_JSON=$(aws secretsmanager get-secret-value \
  --region "$AWS_REGION" \
  --secret-id "$DB_SECRET_ARN" \
  --query SecretString \
  --output text)

DB_USERNAME=$(echo "$DB_SECRET_JSON" | jq -r '.db_username')
DB_PASSWORD=$(echo "$DB_SECRET_JSON" | jq -r '.db_password')

DB_USERNAME_URL=$(printf '%s' "$DB_USERNAME" | jq -sRr @uri)
DB_PASSWORD_URL=$(printf '%s' "$DB_PASSWORD" | jq -sRr @uri)

DATABASE_URL="postgresql://$DB_USERNAME_URL:$DB_PASSWORD_URL@$DB_HOST:$DB_PORT/$DB_NAME"

sudo docker run -d \
  -p 3000:8080 \
  -e OLLAMA_BASE_URL="http://$DNS_NAME" \
  -e DATABASE_URL="$DATABASE_URL" \
  -e VECTOR_DB="pgvector" \
  -e PGVECTOR_CREATE_EXTENSION="false" \
  -v open-webui-data:/app/backend/data \
  --name open-webui \
  --restart always \
  ghcr.io/open-webui/open-webui:main-slim
