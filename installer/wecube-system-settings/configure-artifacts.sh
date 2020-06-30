#!/bin/bash

set -e

SYS_SETTINGS_ENV_FILE=$1

source $SYS_SETTINGS_ENV_FILE

([ -z "$ARTIFACTS_COS_REGION" ] || [ -z "$ARTIFACTS_COS_BUCKET" ] || [ -z "$ARTIFACTS_COS_OBJECTS" ]) && \
  echo "No artifact packages are specified and skipped uploading." && exit 0

echo "Downloading artifact packages from TencentCloud COS..."
PYTHON_SCRIPT_FILE=$(realpath "./download-objects-in-bucket.py")
DOWNLOAD_DIR=$(realpath "./download")
mkdir -p "$DOWNLOAD_DIR"
docker run --rm -t \
  -v "$PYTHON_SCRIPT_FILE:$PYTHON_SCRIPT_FILE" \
  -v "$DOWNLOAD_DIR:$DOWNLOAD_DIR" \
  python:3 /bin/sh -c """
  pip install -i https://pypi.tuna.tsinghua.edu.cn/simple -U cos-python-sdk-v5 && \
  python $PYTHON_SCRIPT_FILE \
    $ARTIFACTS_COS_SECRETID $ARTIFACTS_COS_SECRETKEY \
    $ARTIFACTS_COS_REGION $ARTIFACTS_COS_BUCKET \"${ARTIFACTS_COS_OBJECTS[*]}\" \
    $DOWNLOAD_DIR
  """

echo "Generating MD5 checksums..."
for FILE in "$DOWNLOAD_DIR"/*; do
  BASE_FILE_NAME=$(basename $FILE)
  MD5_CHECKSUM=$(md5sum "$FILE" | awk '{ print $1 }')
  if [ "${BASE_FILE_NAME:0:33}" == "${MD5_CHECKSUM}_" ]; then
    echo "Skipped file $BASE_FILE_NAME"
  else
    FILE_NAME_WITH_MD5_CHECKSUM="${DOWNLOAD_DIR}/${MD5_CHECKSUM}_${BASE_FILE_NAME}"
    echo "Processed file $FILE_NAME_WITH_MD5_CHECKSUM"
    mv "$FILE" "$FILE_NAME_WITH_MD5_CHECKSUM"
  fi
done

echo "Uploading artifacts..."
SHELL_SCRIPT_FILE=$(realpath "./upload-all-files-in-dir-to-minio.sh")
docker run --rm -t \
  -v "$DOWNLOAD_DIR:$DOWNLOAD_DIR" \
  -v "$SHELL_SCRIPT_FILE:$SHELL_SCRIPT_FILE" \
  --env "S3_URL=$S3_URL" --env "S3_ACCESS_KEY=$S3_ACCESS_KEY"  --env "S3_SECRET_KEY=$S3_SECRET_KEY" \
  --env "DOWNLOAD_DIR=$DOWNLOAD_DIR" --env "ARTIFACTS_S3_BUCKET_NAME=$ARTIFACTS_S3_BUCKET_NAME" \
  --entrypoint=/bin/sh \
  minio/mc "$SHELL_SCRIPT_FILE"
