#!/bin/bash

SCRIPT_DIR=$(realpath $(dirname "$0"))
INSTALLER_LOG_DIR="./installer-logs"
mkdir -p $INSTALLER_LOG_DIR

#### Configuration Section ####
install_target_host_default='127.0.0.1'
wecube_release_version_default='latest'
wecube_settings_default='standard'
dest_dir_default='/data/wecube'
wecube_user_default='wecube'
initial_password_default='Wecube@123456'
use_mirror_in_mainland_china_default='true'
#### End of Configuration Section ####

set -e
trap 'catch $? $LINENO' EXIT

catch() {
	[ "$1" == '0' ] && exit 0

	pushd $SCRIPT_DIR >/dev/null
	LOG_COLLECT_DIR=$(realpath "$INSTALLER_LOG_DIR")
	echo -e "\n\e[0;33mCollecting WeCube logs into $LOG_COLLECT_DIR after error occurred...\e[0m"
	cp -R $SCRIPT_DIR/out.log $dest_dir/logs/* $LOG_COLLECT_DIR/
	cp -R $dest_dir/wecmdb/log/* $LOG_COLLECT_DIR/wecmdb/
	cp -R $dest_dir/monitor/logs/* $LOG_COLLECT_DIR/monitor/

	LOG_FILE_ARCHIVE="wecube-logs.tar.gz"
	tar czvf $LOG_FILE_ARCHIVE $INSTALLER_LOG_DIR
	echo "WeCube installation logs saved to file ${LOG_FILE_ARCHIVE}"
	popd >/dev/null

	exit 1
}

read -p "Please specify host IP address ($install_target_host_default): " install_target_host
install_target_host=${install_target_host:-$install_target_host_default}

read -p "Please specify WeCube release version [latest, v2.7.0, ...] ($wecube_release_version_default): " wecube_release_version
wecube_release_version=${wecube_release_version:-$wecube_release_version_default}

read -p "Please specify WeCube settings [standard, bootcamp, empty] ($wecube_settings_default): " wecube_settings
wecube_settings=${wecube_settings:-$wecube_settings_default}

read -p "Please specify destination dir ($dest_dir_default): " dest_dir
dest_dir=${dest_dir:-$dest_dir_default}

read -p "Please specify wecube user ($wecube_user_default): " wecube_user
wecube_user=${wecube_user:-$wecube_user_default}

read -s -p "Please enter password for wecube user and mysql root user ($initial_password_default): " initial_password_1 && echo ""
[ -n "$initial_password_1" ] && read -s -p "Please re-enter the password to confirm: " initial_password_2 && echo ""
[ -n "$initial_password_1" ] && [ "$initial_password_1" != "$initial_password_2" ] && echo 'Inputs do not match!' && exit 1
initial_password=${initial_password_1:-$initial_password_default}

read -p "Please specify whether mirror sites in Mainland China should be used ($use_mirror_in_mainland_china_default): " use_mirror_in_mainland_china
use_mirror_in_mainland_china=${use_mirror_in_mainland_china:-$use_mirror_in_mainland_china_default}

echo ""
cat <<-EOF | tee "$INSTALLER_LOG_DIR/input-params.log"
- install_target_host          = ${install_target_host}
- wecube_release_version       = ${wecube_release_version}
- wecube_settings              = ${wecube_settings}
- dest_dir                     = ${dest_dir}
- wecube_user                  = ${wecube_user}
- initial_password             = (*not shown*)
- use_mirror_in_mainland_china = ${use_mirror_in_mainland_china}
EOF

read -p "Continue? [y/Y] " -n 1 -r && echo ""
[[ ! $REPLY =~ ^[Yy]$ ]] && echo "Installation aborted." && exit 1

sudo mkdir -p $dest_dir
sudo chown -R $USER:$USER $dest_dir

INSTALLER_URL="https://github.com/WeBankPartners/delivery-by-terraform/archive/master.zip"
INSTALLER_PKG="$dest_dir/wecube-installer.zip"
INSTALLER_DIR="$dest_dir/installer"
INSTALLER_SOURCE_CODE_DIR="$dest_dir/delivery-by-terraform-master/installer"

if [ "$use_mirror_in_mainland_china" == "true" ]; then
  echo 'Using Gitee as mirror for WeCube code repository in Mainland China.'
  INSTALLER_URL="https://gitee.com/WeBankPartners/delivery-by-terraform/repository/archive/master.zip"
  INSTALLER_SOURCE_CODE_DIR="$dest_dir/delivery-by-terraform/installer"
fi

echo -e "\nFetching WeCube installer from $INSTALLER_URL"
RETRIES=30
while [ $RETRIES -gt 0 ]; do
  if $(curl --connect-timeout 30 --speed-time 30 --speed-limit 1000 -fL $INSTALLER_URL -o $INSTALLER_PKG); then
	break
  else
	RETRIES=$((RETRIES - 1))
	PAUSE=$(( ( RANDOM % 5 ) + 1 ))
	echo "Retry in $PAUSE seconds, $RETRIES times remaining..."
	sleep "$PAUSE"
  fi
done
[ $RETRIES -eq 0 ] && echo 'Failed to fetch installer package! Installation aborted.' && exit 1

unzip -o -q $INSTALLER_PKG -d $dest_dir
cp -R $INSTALLER_SOURCE_CODE_DIR $dest_dir

[ -f $wecube_release_version ] && \
  cp $wecube_release_version "$INSTALLER_DIR/wecube-platform/" && \
  cp $wecube_release_version "$INSTALLER_DIR/wecube-system-settings/"

echo -e "\nRunning WeCube installer scripts...\n"
pushd $INSTALLER_DIR >/dev/null

INSTALLATION_PARAMS_ENV_FILE="$INSTALLER_DIR/installation-params.env"
(umask 066 && cat <<EOF >"$INSTALLATION_PARAMS_ENV_FILE"
DATE_TIME='$(date --rfc-3339=seconds)'
HOST_PRIVATE_IP='${install_target_host}'
WECUBE_RELEASE_VERSION='${wecube_release_version}'
WECUBE_SETTINGS='${wecube_settings}'
WECUBE_HOME='${dest_dir}'
WECUBE_USER='${wecube_user}'
INITIAL_PASSWORD='${initial_password}'
USE_MIRROR_IN_MAINLAND_CHINA='${use_mirror_in_mainland_china}'
EOF
)
./invoke-installer.sh "$INSTALLATION_PARAMS_ENV_FILE" params-validator

PROVISIONING_ENV_FILE="$INSTALLER_DIR/provisioning.env"
(umask 066 && cat <<EOF >"$PROVISIONING_ENV_FILE"
DATE_TIME='$(date --rfc-3339=seconds)'
HOST_PRIVATE_IP='${install_target_host}'
WECUBE_RELEASE_VERSION='${wecube_release_version}'
WECUBE_SETTINGS='${wecube_settings}'
WECUBE_HOME='${dest_dir}'
WECUBE_USER='${wecube_user}'
INITIAL_PASSWORD='${initial_password}'
USE_MIRROR_IN_MAINLAND_CHINA='${use_mirror_in_mainland_china}'

DOCKER_PORT=2375

S3_PORT=9000
S3_ACCESS_KEY=access_key
S3_SECRET_KEY=secret_key

MYSQL_PORT=3307
MYSQL_USERNAME=root
MYSQL_PASSWORD='${initial_password}'
EOF
)
./invoke-installer.sh "$PROVISIONING_ENV_FILE" yum-packages wecube-user docker mysql-docker minio-docker open-monitor-agent

WECUBE_DB_ENV_FILE="$INSTALLER_DIR/db-deployment-wecube-db-standalone.env"
(umask 066 && cat <<EOF >"$WECUBE_DB_ENV_FILE"
DATE_TIME='$(date --rfc-3339=seconds)'
HOST_PRIVATE_IP='${install_target_host}'
WECUBE_RELEASE_VERSION='${wecube_release_version}'
WECUBE_SETTINGS='${wecube_settings}'
WECUBE_HOME='${dest_dir}'
WECUBE_USER='${wecube_user}'
INITIAL_PASSWORD='${initial_password}'
USE_MIRROR_IN_MAINLAND_CHINA='${use_mirror_in_mainland_china}'

DB_HOST='${install_target_host}'
DB_PORT=3307
DB_NAME=wecube
DB_USERNAME=root
DB_PASSWORD='${initial_password}'
EOF
)
./invoke-installer.sh "$WECUBE_DB_ENV_FILE" db-connectivity

AUTH_SERVER_DB_ENV_FILE="$INSTALLER_DIR/db-deployment-auth-server-db-standalone.env"
(umask 066 && cat <<EOF >"$AUTH_SERVER_DB_ENV_FILE"
DATE_TIME='$(date --rfc-3339=seconds)'
HOST_PRIVATE_IP='${install_target_host}'
WECUBE_RELEASE_VERSION='${wecube_release_version}'
WECUBE_SETTINGS='${wecube_settings}'
WECUBE_HOME='${dest_dir}'
WECUBE_USER='${wecube_user}'
INITIAL_PASSWORD='${initial_password}'
USE_MIRROR_IN_MAINLAND_CHINA='${use_mirror_in_mainland_china}'

DB_HOST='${install_target_host}'
DB_PORT=3307
DB_NAME=auth_server
DB_USERNAME=root
DB_PASSWORD='${initial_password}'
EOF
)
./invoke-installer.sh "$AUTH_SERVER_DB_ENV_FILE" db-connectivity

WECUBE_PLATFORM_ENV_FILE="$INSTALLER_DIR/app-deployment-wecube-platform-standalone.env"
(umask 066 && cat <<EOF >"$WECUBE_PLATFORM_ENV_FILE"
DATE_TIME='$(date --rfc-3339=seconds)'
HOST_PRIVATE_IP='${install_target_host}'
WECUBE_RELEASE_VERSION='${wecube_release_version}'
WECUBE_SETTINGS='${wecube_settings}'
WECUBE_HOME='${dest_dir}'
WECUBE_USER='${wecube_user}'
INITIAL_PASSWORD='${initial_password}'
USE_MIRROR_IN_MAINLAND_CHINA='${use_mirror_in_mainland_china}'

STATIC_RESOURCE_HOSTS='${install_target_host}'
S3_HOST='${install_target_host}'

CORE_DB_HOST='${install_target_host}'
CORE_DB_PORT=3307
CORE_DB_NAME=wecube
CORE_DB_USERNAME=root
CORE_DB_PASSWORD='${initial_password}'

AUTH_SERVER_DB_HOST='${install_target_host}'
AUTH_SERVER_DB_PORT=3307
AUTH_SERVER_DB_NAME=auth_server
AUTH_SERVER_DB_USERNAME=root
AUTH_SERVER_DB_PASSWORD='${initial_password}'

PLUGIN_DB_HOST='${install_target_host}'
PLUGIN_DB_PORT=3307
PLUGIN_DB_NAME=mysql
PLUGIN_DB_USERNAME=root
PLUGIN_DB_PASSWORD='${initial_password}'
EOF
)
./invoke-installer.sh "$WECUBE_PLATFORM_ENV_FILE" wecube-platform

WECUBE_PLUGIN_HOSTING_ENV_FILE="$INSTALLER_DIR/app-deployment-wecube-plugin-hosting-standalone.env"
(umask 066 && cat <<EOF >"$WECUBE_PLUGIN_HOSTING_ENV_FILE"
DATE_TIME='$(date --rfc-3339=seconds)'
HOST_PRIVATE_IP='${install_target_host}'
WECUBE_RELEASE_VERSION='${wecube_release_version}'
WECUBE_SETTINGS='${wecube_settings}'
WECUBE_HOME='${dest_dir}'
WECUBE_USER='${wecube_user}'
INITIAL_PASSWORD='${initial_password}'
USE_MIRROR_IN_MAINLAND_CHINA='${use_mirror_in_mainland_china}'

CORE_HOST='${install_target_host}'

CORE_DB_HOST='${install_target_host}'
CORE_DB_PORT=3307
CORE_DB_NAME=wecube
CORE_DB_USERNAME=root
CORE_DB_PASSWORD='${initial_password}'
EOF
)
./invoke-installer.sh "$WECUBE_PLUGIN_HOSTING_ENV_FILE" wecube-plugin-hosting

WECUBE_SYSTEM_SETTINGS_ENV_FILE="$INSTALLER_DIR/app-deployment-wecube-system-settings-standalone.env"
(umask 066 && cat <<EOF >"$WECUBE_SYSTEM_SETTINGS_ENV_FILE"
DATE_TIME='$(date --rfc-3339=seconds)'
HOST_PRIVATE_IP='${install_target_host}'
WECUBE_RELEASE_VERSION='${wecube_release_version}'
WECUBE_SETTINGS='${wecube_settings}'
WECUBE_HOME='${dest_dir}'
WECUBE_USER='${wecube_user}'
INITIAL_PASSWORD='${initial_password}'
USE_MIRROR_IN_MAINLAND_CHINA='${use_mirror_in_mainland_china}'

S3_ACCESS_KEY=access_key
S3_SECRET_KEY=secret_key
AGENT_S3_BUCKET_NAME=wecube-agent
ARTIFACTS_S3_BUCKET_NAME=wecube-artifacts

CORE_HOST='${install_target_host}'
S3_HOST='${install_target_host}'
PLUGIN_HOST='${install_target_host}'
PORTAL_HOST='${install_target_host}'

CORE_DB_HOST='${install_target_host}'
CORE_DB_PORT=3307
CORE_DB_NAME=wecube
CORE_DB_USERNAME=root
CORE_DB_PASSWORD='${initial_password}'

AUTH_SERVER_DB_HOST='${install_target_host}'
AUTH_SERVER_DB_PORT=3307
AUTH_SERVER_DB_NAME=auth_server
AUTH_SERVER_DB_USERNAME=root
AUTH_SERVER_DB_PASSWORD='${initial_password}'

PLUGIN_DB_HOST='${install_target_host}'
PLUGIN_DB_PORT=3307
PLUGIN_DB_NAME=mysql
PLUGIN_DB_USERNAME=root
PLUGIN_DB_PASSWORD='${initial_password}'
EOF
)
./invoke-installer.sh "$WECUBE_SYSTEM_SETTINGS_ENV_FILE" wecube-system-settings

popd >/dev/null

echo -e "\n\nWeCube installation completed. Please visit WeCube at http://${install_target_host}:19090\n"
