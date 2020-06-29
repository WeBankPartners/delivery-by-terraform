#!/bin/bash

set -e

mc config host add wecubeS3 "$S3_URL" "$S3_ACCESS_KEY" "$S3_SECRET_KEY"

for FILE in "$DOWNLOAD_DIR"/*; do
  mc cp $FILE wecubeS3/"$ARTIFACTS_S3_BUCKET_NAME"
done
