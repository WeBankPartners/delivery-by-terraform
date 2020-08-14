#!/bin/bash

set -e

SYS_SETTINGS_ENV_FILE=$1

source $SYS_SETTINGS_ENV_FILE

([ -z "$ARTIFACTS_COS_REGION" ] || [ -z "$ARTIFACTS_COS_BUCKET" ] || [ -z "$ARTIFACTS_COS_OBJECTS" ]) && \
  echo "No artifacts are specified and skipped uploading." && exit 0

echo "Downloading artifacts from TencentCloud COS..."
PYTHON_SCRIPT_FILE=$(realpath "./download-objects-in-bucket.py")
DOWNLOAD_DIR=$(realpath "./download")
mkdir -p "$DOWNLOAD_DIR"

PIP_INSTALL_CMD="pip install -U crcmod cos-python-sdk-v5"
if [ "$USE_MIRROR_IN_MAINLAND_CHINA" == "true" ]; then
  echo 'Using mirror for pip index in Mainland China.'
  PIP_INSTALL_CMD="pip install -i https://pypi.tuna.tsinghua.edu.cn/simple -U crcmod cos-python-sdk-v5"
fi
docker run --rm -t \
  -v "$PYTHON_SCRIPT_FILE:$PYTHON_SCRIPT_FILE" \
  -v "$DOWNLOAD_DIR:$DOWNLOAD_DIR" \
  python:3 /bin/sh -c """
  $PIP_INSTALL_CMD && \
  python $PYTHON_SCRIPT_FILE \
    $ARTIFACTS_COS_SECRETID $ARTIFACTS_COS_SECRETKEY \
    $ARTIFACTS_COS_REGION $ARTIFACTS_COS_BUCKET \"${ARTIFACTS_COS_OBJECTS[*]}\" \
    $DOWNLOAD_DIR
  """

find "$DOWNLOAD_DIR" -type f | while read FILE; do
  BASE_NAME=$(basename $FILE)
  DIR_NAME=$(dirname $FILE)
  MD5_CHECKSUM=$(md5sum "$FILE" | awk '{ print $1 }')
  if [ "${BASE_NAME:0:33}" == "${MD5_CHECKSUM}_" ]; then
    echo "Skipped file $BASE_NAME"
  else
    FILE_WITH_MD5_CHECKSUM="${DIR_NAME}/${MD5_CHECKSUM}_${BASE_NAME}"
    echo "Processed file $FILE_WITH_MD5_CHECKSUM"
    mv "$FILE" "$FILE_WITH_MD5_CHECKSUM"
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
