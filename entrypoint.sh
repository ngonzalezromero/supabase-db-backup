#!/usr/bin/env bash

set -euo pipefail

DATABASE_NAME="${DATABASE_NAME}"
AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}"
AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}"
DATABASE_USER="${DATABASE_USER}"
DATABASE_PASSWORD="${DATABASE_PASSWORD}"
DATABASE_HOST="${DATABASE_HOST}"
DATABASE_PORT="${DATABASE_PORT}"
S3_BUCKET_NAME="${S3_BUCKET_NAME}"

TIMESTAMP="$(date +%s)"

DUMP_FILE="db-dump-${TIMESTAMP}.sql.gz"


aws configure set aws_access_key_id "${AWS_ACCESS_KEY_ID}"
aws configure set aws_secret_access_key "${AWS_SECRET_ACCESS_KEY}"
aws configure set default.region "us-west-2"

echo "Creating dump at s3://${S3_BUCKET_NAME}/database-backups/${DATABASE_NAME}/${DUMP_FILE}"

pg_dump "postgresql://${DATABASE_USER}:${DATABASE_PASSWORD}@${DATABASE_HOST}:${DATABASE_PORT}/${DATABASE_NAME}?sslmode=require" -n public -v   | gzip > "${DUMP_FILE}"
echo "Dump complete. Uploading..."

#configure aws credentials for s3
aws configure set aws_access_key_id "${AWS_ACCESS_KEY_ID}"
aws configure set aws_secret_access_key "${AWS_SECRET_ACCESS_KEY}"
aws configure set default.region "us-west-2"

#send to s3
aws s3 cp "${DUMP_FILE}" "s3://${S3_BUCKET_NAME}/database-backups/${DATABASE_NAME}/${DUMP_FILE}"

echo "Upload complete. Cleaning up..."

