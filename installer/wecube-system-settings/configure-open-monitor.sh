#!/bin/bash

set -e

SYS_SETTINGS_ENV_FILE=$1
COLLECTION_DIR=$2
PLUGIN_PKG_DIR=$3

source $SYS_SETTINGS_ENV_FILE

echo -e "\nConfiguring plugin Open-Monitor..."

echo -e "\nRegistering monitoring target objects...\n"
docker run --rm -t \
	-v "$COLLECTION_DIR:$COLLECTION_DIR" \
	postman/newman \
	run "$COLLECTION_DIR/021_wecube_init_plugin.postman_collection.json" \
	--env-var "domain=$PUBLIC_DOMAIN" \
	--env-var "username=$DEFAULT_ADMIN_USERNAME" \
	--env-var "password=$DEFAULT_ADMIN_PASSWORD" \
	--env-var "wecube_host=$CORE_HOST" \
	--env-var "plugin_host=$PLUGIN_HOST" \
	--env-var "node_exporter_port=$MONITOR_AGENT_PORT" \
	--env-var "plugin_mysql_host=$PLUGIN_DB_HOST" \
	--env-var "plugin_mysql_port=$PLUGIN_DB_PORT" \
	--env-var "plugin_mysql_user=$PLUGIN_DB_USERNAME" \
	--env-var "plugin_mysql_password=$PLUGIN_DB_PASSWORD" \
	--env-var "core_host=$CORE_HOST" \
	--env-var "core_jmx_port=$WECUBE_SERVER_JMX_PORT" \
	--delay-request 2000 --disable-unicode \
	--reporters cli \
	--reporter-cli-no-banner --reporter-cli-no-console

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
	--entrypoint=/bin/sh minio/mc -c "$SHELL_CMD"

read -d '' SQL_STMT <<-EOF || true
	UPDATE ``wecube``.``system_variables``
	   SET value = '$S3_URL/$AGENT_S3_BUCKET_NAME/$AGENT_PKG_FILENAME'
	 WHERE name ='HOST_EXPORTER_S3_PATH';
EOF
../execute-sql-statements.sh $CORE_DB_HOST $CORE_DB_PORT \
	$CORE_DB_NAME $CORE_DB_USERNAME $CORE_DB_PASSWORD \
	"$SQL_STMT"
