#!/bin/bash

set -e

ENV_FILE=$1
source $ENV_FILE

mc config host add wecubeS3 "$S3_URL" "$S3_ACCESS_KEY" "$S3_SECRET_KEY"

for FILE in "$DOWNLOAD_DIR"/*; do
  mc cp $FILE wecubeS3/"$ARTIFACTS_BUCKET_NAME"
done
