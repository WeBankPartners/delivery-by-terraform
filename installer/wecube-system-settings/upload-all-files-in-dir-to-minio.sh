#!/bin/bash

set -e

ENV_FILE=$1
source $ENV_FILE

mc config host add wecubeS3 "http://$S3_HOST:9000" "$S3_ACCESS_KEY" "$S3_SECRET_KEY"

for FILE in "$DOWNLOAD_DIR"/*; do
  mc cp $FILE wecubeS3/"$S3_BUCKET_NAME"
done
