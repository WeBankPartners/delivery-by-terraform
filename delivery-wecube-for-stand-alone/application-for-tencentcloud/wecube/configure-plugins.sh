#!/bin/bash

set -e

CONFIG_FILE=$1; shift
PLUGIN_PKGS=( "$@" )

[ ! -f $CONFIG_FILE ] && echo "Invalid configuration file: $CONFIG_FILE" && exit 1
source $CONFIG_FILE

echo -e "\nNow starting to configure plugins...\n"

WECUBE_HOST="$install_target_host"
PLUGIN_HOST="$install_target_host"

PLUGIN_INSTALLER_URL="https://github.com/WeBankPartners/wecube-auto/archive/master.zip"
PLUGINS_BUCKET_URL="https://wecube-1259801214.cos.ap-guangzhou.myqcloud.com"
PLUGIN_INSTALLER_PKG="$installer_dir/wecube-plugin-installer.zip"
PLUGIN_INSTALLER_DIR="$installer_dir/wecube-plugin-installer"
COLLECTION_DIR="$PLUGIN_INSTALLER_DIR/wecube-auto-master"
mkdir -p "$PLUGIN_INSTALLER_DIR"
echo "Fetching wecube-plugin-installer from $PLUGIN_INSTALLER_URL"
curl -#L $PLUGIN_INSTALLER_URL -o $PLUGIN_INSTALLER_PKG
unzip -o -q $PLUGIN_INSTALLER_PKG -d $PLUGIN_INSTALLER_DIR

echo -e "\nFetching plugin packages...."
PLUGIN_PKG_DIR="$PLUGIN_INSTALLER_DIR/plugins"
mkdir -p "$PLUGIN_PKG_DIR"
PLUGIN_LIST_CSV="$PLUGIN_PKG_DIR/plugin-list.csv"
echo "plugin_package_path" > $PLUGIN_LIST_CSV
for PLUGIN_URL in "${PLUGIN_PKGS[@]}"; do
    PLUGIN_PKG_FILE="$PLUGIN_PKG_DIR/${PLUGIN_URL##*'/'}"
    echo -e "\nFetching from $PLUGIN_URL"
    curl -L $PLUGIN_URL -o $PLUGIN_PKG_FILE
    echo $PLUGIN_PKG_FILE >> $PLUGIN_LIST_CSV
done


echo -e "\nRegistering plugins, this may take a few minutes...\n"
docker run --rm -t \
    -v "$COLLECTION_DIR:$COLLECTION_DIR" \
    -v "$PLUGIN_PKG_DIR:$PLUGIN_PKG_DIR" \
    postman/newman \
    run "$COLLECTION_DIR/020_wecube_plugin_register.postman_collection.json" \
    -d "$PLUGIN_PKG_DIR/plugin-list.csv" \
    --env-var "domain=$public_domain" \
    --env-var "username=$default_admin_username" \
    --env-var "password=$default_admin_password" \
    --env-var "wecube_host=$WECUBE_HOST" \
    --env-var "plugin_host=$PLUGIN_HOST" \
    --delay-request 2000 --disable-unicode \
    --reporters cli \
    --reporter-cli-no-banner --reporter-cli-no-console

echo -e "\nEnabling plugin service configurations..."
./execute_sql_script_file.sh $mysql_server_addr $mysql_server_port \
    $mysql_server_database_name $mysql_user_name $mysql_user_password \
    "$installer_dir/wecube/database/platform-core/05.register_all_plugin_services.sql"


echo -e "\nConfiguring plugin WeCMDB...\n"
docker run --rm -t \
    -v "$COLLECTION_DIR:$COLLECTION_DIR" \
    -v "$PLUGIN_PKG_DIR:$PLUGIN_PKG_DIR" \
    postman/newman \
    run "$COLLECTION_DIR/022_wecube_sync_model.postman_collection.json" \
    --env-var "domain=$public_domain" \
    --env-var "username=$default_admin_username" \
    --env-var "password=$default_admin_password" \
    --env-var "wecube_host=$WECUBE_HOST" \
    --env-var "plugin_host=$PLUGIN_HOST" \
    --delay-request 2000 --disable-unicode \
    --reporters cli \
    --reporter-cli-no-banner --reporter-cli-no-console

SQL_FILE_FOR_UPDATE_ASSET_IDS="$installer_dir/wecube/database/cmdb/01.register_cmdb_asset_ids.sql"
if [ -f $SQL_FILE_FOR_UPDATE_ASSET_IDS ]; then
    echo -e "\nRegistering CMDB asset Ids..."
    ./execute_sql_script_file.sh $mysql_server_addr $mysql_server_port \
        wecmdb_embedded $mysql_user_name $mysql_user_password \
        $SQL_FILE_FOR_UPDATE_ASSET_IDS
fi

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

echo "Registering monitoring objects..."
docker run --rm -t \
    -v "$COLLECTION_DIR:$COLLECTION_DIR" \
    -v "$PLUGIN_PKG_DIR:$PLUGIN_PKG_DIR" \
    postman/newman \
    run "$COLLECTION_DIR/021_wecube_init_plugin.postman_collection.json" \
    --env-var "domain=$public_domain" \
    --env-var "username=$default_admin_username" \
    --env-var "password=$default_admin_password" \
    --env-var "wecube_host=$WECUBE_HOST" \
    --env-var "plugin_host=$PLUGIN_HOST" \
    --env-var "node_exporter_port=$MONITOR_AGENT_PORT" \
    --env-var "plugin_mysql_port=$mysql_server_port" \
    --env-var "plugin_mysql_user=$mysql_user_name" \
    --env-var "plugin_mysql_password=$mysql_user_password" \
    --env-var "core_host=$wecube_core_host" \
    --env-var "core_jmx_port=$wecube_server_jmx_port" \
    --delay-request 2000 --disable-unicode \
    --reporters cli \
    --reporter-cli-no-banner --reporter-cli-no-console

echo "Uploading monitor agent package for future use..."
docker run --rm -t \
    -v "$PLUGIN_PKG_DIR/node_exporter_v2.1.tar.gz:/node_exporter_v2.1.tar.gz" \
    --entrypoint=/bin/sh \
    minio/mc -c """
        mc config host add wecubeS3 $s3_url $s3_access_key $s3_secret_key && \
        mc cp /node_exporter_v2.1.tar.gz wecubeS3/wecube-agent
    """
