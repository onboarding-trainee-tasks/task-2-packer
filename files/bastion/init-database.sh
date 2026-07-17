#!/bin/bash
set -e

AWS_REGION="$1"
DB_SECRET_ARN="$2"
DB_HOST="$3"
DB_PORT="$4"
DB_NAME="$5"

DB_SECRET_JSON=$(aws secretsmanager get-secret-value \
  --region "$AWS_REGION" \
  --secret-id "$DB_SECRET_ARN" \
  --query SecretString \
  --output text)

DB_USERNAME=$(echo "$DB_SECRET_JSON" | jq -r '.db_username')
DB_PASSWORD=$(echo "$DB_SECRET_JSON" | jq -r '.db_password')

PGPASSWORD="$DB_PASSWORD" psql \
  --host="$DB_HOST" \
  --port="$DB_PORT" \
  --username="$DB_USERNAME" \
  --dbname="$DB_NAME" \
  --file=/usr/local/share/db_init.sql
