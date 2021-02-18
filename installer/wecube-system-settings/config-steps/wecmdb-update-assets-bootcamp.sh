echo -e "\nUpdating assets in WeCMDB for bootcamp data set..."

ACCESS_TOKEN=$(../api-utils/login.sh $SYS_SETTINGS_ENV_FILE)


INSTALLED_PLUGIN_PKGS=$(ACCESS_TOKEN="$ACCESS_TOKEN" ../api-utils/get-plugin-packages.sh $SYS_SETTINGS_ENV_FILE)
CMDB_PKG_ID=$(jq -r '.[] | select(.name == "wecmdb") | .id' <<<"$INSTALLED_PLUGIN_PKGS")

CMDB_INSTANCE_JSON=$(ACCESS_TOKEN="$ACCESS_TOKEN" ../api-utils/get-plugin-instance.sh $SYS_SETTINGS_ENV_FILE $CMDB_PKG_ID)
CMDB_INSTANCE_HOST=$(jq --exit-status -r '.host' <<<"$CMDB_INSTANCE_JSON")
CMDB_INSTANCE_PORT=$(jq --exit-status '.port' <<<"$CMDB_INSTANCE_JSON")
CMDB_INSTANCE_NAME=$(jq --exit-status -r '.instanceName' <<<"$CMDB_INSTANCE_JSON")


echo -e "\nCreating CI data entry for data type \"host\"..."
HOST_CI_TYPE_ID='67'
read -d '' HOST_CI_DATA_JSON <<-EOF || true
	[
	  {
	    "code": "WECUBE_HOST",
	    "ip_address": "${CORE_HOST}",
	    "username": "${WECUBE_USER}",
	    "password": "${INITIAL_PASSWORD}"
	  }
	]
EOF
ACCESS_TOKEN="$ACCESS_TOKEN" ../api-utils/wecmdb-batch-create-ci-data.sh $SYS_SETTINGS_ENV_FILE \
	$CMDB_INSTANCE_HOST $CMDB_INSTANCE_PORT $CMDB_INSTANCE_NAME \
	$HOST_CI_TYPE_ID "$HOST_CI_DATA_JSON"


echo -e "\nCreating CI data entry for data type \"artifact\"..."
ARTIFACT_CI_TYPE_ID='68'
read -d '' ARTIFACT_CI_DATA_JSON <<-EOF || true
	[
	  {
	    "code": "bootcamp-app-java-spring-boot_1.0.0",
	    "download_url": "${S3_URL}/${ARTIFACTS_S3_BUCKET_NAME}/ac97667fe83d5ae961206324aeb48e63_bootcamp-app-java-spring-boot_1.0.0.tar.gz",
	    "should_decompress": "true",
	    "deploy_script": "bootcamp-app-java-spring-boot_1.0.0/bin/deploy.sh",
	    "start_script": "bootcamp-app-java-spring-boot_1.0.0/bin/start-current.sh",
	    "stop_script": "bootcamp-app-java-spring-boot_1.0.0/bin/stop-current.sh"
	  }
	]
EOF
ACCESS_TOKEN="$ACCESS_TOKEN" ../api-utils/wecmdb-batch-create-ci-data.sh $SYS_SETTINGS_ENV_FILE \
	$CMDB_INSTANCE_HOST $CMDB_INSTANCE_PORT $CMDB_INSTANCE_NAME \
	$ARTIFACT_CI_TYPE_ID "$ARTIFACT_CI_DATA_JSON"
