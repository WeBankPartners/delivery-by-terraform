#!/bin/bash

set -e

SYS_SETTINGS_ENV_FILE=$1

source $SYS_SETTINGS_ENV_FILE

DOWNLOAD_DIR=$(realpath "./download")
mkdir -p "$DOWNLOAD_DIR"
echo "DOWNLOAD_DIR=$DOWNLOAD_DIR" >>$SYS_SETTINGS_ENV_FILE

echo "Downloading artifacts from TencentCloud COS..."
PYTHON_TEMPLATE_FILE="./download-all-objects-in-bucket.py.tpl"
PYTHON_SCRIPT_FILE=$(realpath "./download-all-objects-in-bucket.py")
../substitute-in-file.sh $SYS_SETTINGS_ENV_FILE "$PYTHON_TEMPLATE_FILE" "$PYTHON_SCRIPT_FILE"
docker run --rm -t \
  -v "$DOWNLOAD_DIR:$DOWNLOAD_DIR" \
  -v "$PYTHON_SCRIPT_FILE:$PYTHON_SCRIPT_FILE" \
  python:3 sh -c \
  "pip install -i https://pypi.tuna.tsinghua.edu.cn/simple -U cos-python-sdk-v5 && python $PYTHON_SCRIPT_FILE"

echo "Generating MD5 checksums..."
for FILE in "$DOWNLOAD_DIR"/*; do
  BASE_FILE_NAME=$(basename $FILE)
  MD5_CHECKSUM=$(md5sum "$FILE" | awk '{ print $1 }')
  FILE_NAME_WITH_MD5_CHECKSUM="${DOWNLOAD_DIR}/${MD5_CHECKSUM}_${BASE_FILE_NAME}"
  echo "Processed file $FILE_NAME_WITH_MD5_CHECKSUM"
  mv "$FILE" "$FILE_NAME_WITH_MD5_CHECKSUM"
done

echo "Uploading artifacts..."
SHELL_SCRIPT_FILE=$(realpath "./upload-all-files-in-dir-to-minio.sh")
SYS_SETTINGS_ENV_FILE_PATH=$(realpath "$SYS_SETTINGS_ENV_FILE")
docker run --rm -t \
  -v "$DOWNLOAD_DIR:$DOWNLOAD_DIR" \
  -v "$SYS_SETTINGS_ENV_FILE_PATH:$SYS_SETTINGS_ENV_FILE_PATH" \
  -v "$SHELL_SCRIPT_FILE:$SHELL_SCRIPT_FILE" \
  --entrypoint=/bin/sh \
  minio/mc "$SHELL_SCRIPT_FILE" "$SYS_SETTINGS_ENV_FILE_PATH"
