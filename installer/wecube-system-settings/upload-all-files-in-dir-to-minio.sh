#!/bin/bash

set -e

mc config host add wecubeS3 "$S3_URL" "$S3_ACCESS_KEY" "$S3_SECRET_KEY"

find "$DOWNLOAD_DIR" -type f | while read FILE; do
  mc cp "$FILE" "wecubeS3/$ARTIFACTS_S3_BUCKET_NAME/$(basename $FILE)"
done
