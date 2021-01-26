echo -e "\nConfiguring plugin Open-Monitor..."

echo -e "\nUploading monitor agent package for future use...\n"
AGENT_PKG_FILENAME="node_exporter.tar.gz"
AGENT_PKG_PATH="$PLUGIN_PKG_DIR/$AGENT_PKG_FILENAME"
AGENT_PKG_URL="https://wecube-1259801214.cos.ap-guangzhou.myqcloud.com/monitor_agent/$AGENT_PKG_FILENAME"
echo "Fetching agent package from $AGENT_PKG_URL ..."
../curl-with-retry.sh -fL $AGENT_PKG_URL -o $AGENT_PKG_PATH

echo "Saving agent package to S3 server..."
read -d '' SHELL_CMD <<-EOF || true
	mc config host add wecubeS3 $S3_URL $S3_ACCESS_KEY $S3_SECRET_KEY && \
	mc cp /$AGENT_PKG_FILENAME wecubeS3/$AGENT_S3_BUCKET_NAME
EOF
docker run --rm -t \
	-v "$AGENT_PKG_PATH:/$AGENT_PKG_FILENAME" \
	--entrypoint=/bin/sh \
	minio/mc:RELEASE.2020-11-25T23-04-07Z -c "$SHELL_CMD"

read -d '' SQL_STMT <<-EOF || true
	UPDATE ``wecube``.``system_variables``
	   SET value = '$S3_URL/$AGENT_S3_BUCKET_NAME/$AGENT_PKG_FILENAME'
	 WHERE name ='HOST_EXPORTER_S3_PATH';
EOF
../execute-sql-statements.sh $CORE_DB_HOST $CORE_DB_PORT \
	$CORE_DB_NAME $CORE_DB_USERNAME $CORE_DB_PASSWORD \
	"$SQL_STMT"


echo -e "\nRegistering monitoring target objects for hosts...\n"
../api-utils/register-monitoring-targets-host.sh $SYS_SETTINGS_ENV_FILE

echo -e "\nRegistering monitoring target objects for Java applications...\n"
../api-utils/register-monitoring-targets-java.sh $SYS_SETTINGS_ENV_FILE

echo -e "\nRegistering monitoring target objects for MySQL databases...\n"
../api-utils/register-monitoring-targets-mysql.sh $SYS_SETTINGS_ENV_FILE
