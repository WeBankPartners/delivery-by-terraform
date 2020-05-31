#!/bin/sh

set -e

WECUBE_HOST=$1
COLLECTION_DIR=$2
PLUGIN_PKG_DIR=$3
MYSQL_PASSWORD=$4

PLUGIN_HOST="$WECUBE_HOST"
MINIO_HOST="$WECUBE_HOST"
MINIO_PORT=9000

echo -e "\nRegistering plugins, this may take a few minutes...\n"
docker run --rm -t \
    -v "$COLLECTION_DIR:$COLLECTION_DIR" \
    -v "$PLUGIN_PKG_DIR:$PLUGIN_PKG_DIR" \
    postman/newman \
    run "$COLLECTION_DIR/020_wecube_plugin_register.postman_collection.json" \
    --env-var "domain=$WECUBE_HOST:19090" \
    --env-var "username=umadmin" \
    --env-var "password=umadmin" \
    --env-var "wecube_host=$WECUBE_HOST" \
    --env-var "plugin_host=$PLUGIN_HOST" \
    -d "$PLUGIN_PKG_DIR/plugin-list.csv" \
    --delay-request 2000 --disable-unicode \
    --reporters cli \
    --reporter-cli-no-banner --reporter-cli-no-console

echo -e "\nConfiguring plugin WeCMDB...\n"
docker run --rm -t \
    -v "$COLLECTION_DIR:$COLLECTION_DIR" \
    -v "$PLUGIN_PKG_DIR:$PLUGIN_PKG_DIR" \
    postman/newman \
    run "$COLLECTION_DIR/022_wecube_sync_model.postman_collection.json" \
    --env-var "domain=$WECUBE_HOST:19090" \
    --env-var "username=umadmin" \
    --env-var "password=umadmin" \
    --env-var "wecube_host=$WECUBE_HOST" \
    --env-var "plugin_host=$PLUGIN_HOST" \
    --delay-request 2000 --disable-unicode \
    --reporters cli \
    --reporter-cli-no-banner --reporter-cli-no-console

echo -e "\nConfiguring plugin Open-Monitor...\n"
echo "Fetching monitor agent package..."
MONITOR_AGENT_URL="https://wecube-1259801214.cos.ap-guangzhou.myqcloud.com/monitor_agent/node_exporter_v2.1.tar.gz"
MONITOR_AGENT_PKG_FILE="$PLUGIN_PKG_DIR/node_exporter_v2.1.tar.gz"
MONITOR_AGENT_PORT=9100
curl -#L $MONITOR_AGENT_URL -o $MONITOR_AGENT_PKG_FILE
tar xzf $MONITOR_AGENT_PKG_FILE -C $PLUGIN_PKG_DIR
pushd "$PLUGIN_PKG_DIR/node_exporter_v2.1" >/dev/null
echo "Installing monitor agent..."
sh ./start.sh
popd >/dev/null
./wait-for-it.sh -t 60 $WECUBE_HOST:$MONITOR_AGENT_PORT

echo "Configuring monitoring objects..."
docker run --rm -t \
    -v "$COLLECTION_DIR:$COLLECTION_DIR" \
    -v "$PLUGIN_PKG_DIR:$PLUGIN_PKG_DIR" \
    postman/newman \
    run "$COLLECTION_DIR/021_wecube_init_plugin.postman_collection.json" \
    --env-var "domain=$WECUBE_HOST:19090" \
    --env-var "username=umadmin" \
    --env-var "password=umadmin" \
    --env-var "wecube_host=$WECUBE_HOST" \
    --env-var "plugin_host=$PLUGIN_HOST" \
    --env-var "node_exporter_port=$MONITOR_AGENT_PORT" \
    --env-var "plugin_mysql_port=3307" \
    --env-var "plugin_mysql_user=root" \
    --env-var "plugin_mysql_password=$MYSQL_PASSWORD" \
    --delay-request 2000 --disable-unicode \
    --reporters cli \
    --reporter-cli-no-banner --reporter-cli-no-console

echo "Uploading monitor agent package for future use..."
docker run --rm -t \
    -v "$PLUGIN_PKG_DIR/node_exporter_v2.1.tar.gz:/node_exporter_v2.1.tar.gz" \
    --entrypoint=/bin/sh \
    minio/mc -c """
        mc config host add wecubeS3 http://$MINIO_HOST:$MINIO_PORT access_key secret_key && \
        mc cp /node_exporter_v2.1.tar.gz wecubeS3/wecube-agent
    """
