echo -e "\nConfiguring artifacts..."

DOWNLOAD_DIR=$(realpath "./download")
mkdir -p "$DOWNLOAD_DIR"

for ARTIFACT_URL in "${ARTIFACTS_PKGS[@]}"; do
	ARTIFACT_FILE="$DOWNLOAD_DIR/${ARTIFACT_URL##*'/'}"
	echo "Fetching artifact from $ARTIFACT_URL"
	../curl-with-retry.sh -fL $ARTIFACT_URL -o $ARTIFACT_FILE
done

echo -e "\nUploading artifacts to plugin storage..."
SHELL_SCRIPT_FILE=$(realpath "./upload-all-files-in-dir-to-minio.sh")
docker run --rm -t \
	-v "$DOWNLOAD_DIR:$DOWNLOAD_DIR" \
	-v "$SHELL_SCRIPT_FILE:$SHELL_SCRIPT_FILE" \
	--env "S3_URL=$S3_URL" --env "S3_ACCESS_KEY=$S3_ACCESS_KEY"  --env "S3_SECRET_KEY=$S3_SECRET_KEY" \
	--env "DOWNLOAD_DIR=$DOWNLOAD_DIR" --env "ARTIFACTS_S3_BUCKET_NAME=$ARTIFACTS_S3_BUCKET_NAME" \
	--env "SHOULD_CREATE_ARTIFACTS_BUCKET=$SHOULD_CREATE_ARTIFACTS_BUCKET" \
	--entrypoint=/bin/sh \
	minio/mc:RELEASE.2020-11-25T23-04-07Z "$SHELL_SCRIPT_FILE"
