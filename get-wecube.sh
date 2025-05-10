#!/bin/bash

SECONDS=0
SCRIPT_DIR=$(realpath $(dirname "$0"))
INSTALLER_LOG_DIR="./installer-logs"
mkdir -p $INSTALLER_LOG_DIR

set -e
trap 'catch $? $LINENO' EXIT

catch() {
	[ "$1" == '0' ] && exit 0

	echo -e "\n\e[0;31mError occurred during installation at line $2.\e[0m\n"
	pushd $SCRIPT_DIR >/dev/null
	LOG_COLLECT_DIR=$(realpath "$INSTALLER_LOG_DIR")
	echo -e "\n\e[0;33mCollecting WeCube logs into \"$LOG_COLLECT_DIR\"...\e[0m"
	cp -R $SCRIPT_DIR/out.log $WECUBE_HOME/logs/* $LOG_COLLECT_DIR/
	cp -R $WECUBE_HOME/wecmdb/log/* $LOG_COLLECT_DIR/wecmdb/
	cp -R $WECUBE_HOME/monitor/logs/* $LOG_COLLECT_DIR/monitor/

	LOG_FILE_ARCHIVE="wecube-logs.tar.gz"
	tar czvf $LOG_FILE_ARCHIVE $INSTALLER_LOG_DIR
	echo "WeCube installation logs saved to file ${LOG_FILE_ARCHIVE}"
	popd >/dev/null

	exit 1
}


echo -e "\nPlease specify the configuration parameters for WeCube installation.\n"
#### Configuration Section ####
INSTALL_TARGET_HOST_DEFAULT='127.0.0.1'
WECUBE_RELEASE_VERSION_DEFAULT='latest'
WECUBE_SETTINGS_DEFAULT='standard'
WECUBE_HOME_DEFAULT='/data/wecube'
WECUBE_USER_DEFAULT='root'
INITIAL_PASSWORD_DEFAULT='Wecube@123456'
USE_MIRROR_IN_MAINLAND_CHINA_DEFAULT='false'
#### End of Configuration Section ####

read -p "- Host [$INSTALL_TARGET_HOST_DEFAULT]: " INSTALL_TARGET_HOST
INSTALL_TARGET_HOST=${INSTALL_TARGET_HOST:-$INSTALL_TARGET_HOST_DEFAULT}

read -p "- WeCube release version (latest, v2.7.0, ...) [$WECUBE_RELEASE_VERSION_DEFAULT]: " WECUBE_RELEASE_VERSION
WECUBE_RELEASE_VERSION=${WECUBE_RELEASE_VERSION:-$WECUBE_RELEASE_VERSION_DEFAULT}

read -p "- WeCube settings (standard, bootcamp, empty, init) [$WECUBE_SETTINGS_DEFAULT]: " WECUBE_SETTINGS
WECUBE_SETTINGS=${WECUBE_SETTINGS:-$WECUBE_SETTINGS_DEFAULT}

read -p "- WeCube installation directory [$WECUBE_HOME_DEFAULT]: " WECUBE_HOME
WECUBE_HOME=${WECUBE_HOME:-$WECUBE_HOME_DEFAULT}

read -p "- User to run WeCube [$WECUBE_USER_DEFAULT]: " WECUBE_USER
WECUBE_USER=${WECUBE_USER:-$WECUBE_USER_DEFAULT}

read -s -p "- User password (As initial password for MySQL root) [$INITIAL_PASSWORD_DEFAULT]: " INITIAL_PASSWORD_1 && echo ""
[ -n "$INITIAL_PASSWORD_1" ] && read -s -p "Please re-enter the password to confirm: " INITIAL_PASSWORD_2 && echo ""
[ -n "$INITIAL_PASSWORD_1" ] && [ "$INITIAL_PASSWORD_1" != "$INITIAL_PASSWORD_2" ] && echo 'Inputs do not match!' && exit 1
INITIAL_PASSWORD=${INITIAL_PASSWORD_1:-$INITIAL_PASSWORD_DEFAULT}

read -p "- Should use mirror sites in Mainland China [$USE_MIRROR_IN_MAINLAND_CHINA_DEFAULT]: " USE_MIRROR_IN_MAINLAND_CHINA
USE_MIRROR_IN_MAINLAND_CHINA=${USE_MIRROR_IN_MAINLAND_CHINA:-$USE_MIRROR_IN_MAINLAND_CHINA_DEFAULT}

echo -e "\nPlease review the following configuration:\n"
cat <<-EOF | tee "$INSTALLER_LOG_DIR/input-params.log"
	- INSTALL_TARGET_HOST          = ${INSTALL_TARGET_HOST}
	- WECUBE_RELEASE_VERSION       = ${WECUBE_RELEASE_VERSION}
	- WECUBE_SETTINGS              = ${WECUBE_SETTINGS}
	- WECUBE_HOME                  = ${WECUBE_HOME}
	- WECUBE_USER                  = ${WECUBE_USER}
	- INITIAL_PASSWORD             = (*hidden*)
	- USE_MIRROR_IN_MAINLAND_CHINA = ${USE_MIRROR_IN_MAINLAND_CHINA}
EOF
echo ""

read -p "Continue? [y/Y] " -n 1 -r && echo ""
[[ ! $REPLY =~ ^[Yy]$ ]] && echo "Installation aborted." && exit 1


sudo mkdir -p $WECUBE_HOME
sudo chown -R $USER:$USER $WECUBE_HOME

INSTALLER_URL="https://github.com/WeBankPartners/delivery-by-terraform/archive/refs/heads/aws.zip"
INSTALLER_PKG="$WECUBE_HOME/wecube-installer.zip"
INSTALLER_DIR="$WECUBE_HOME/installer"
INSTALLER_SOURCE_CODE_DIR="$WECUBE_HOME/delivery-by-terraform-aws/installer"

if [ "$USE_MIRROR_IN_MAINLAND_CHINA" == "true" ]; then
  echo 'Using Gitee as mirror for WeCube code repository in Mainland China.'
  INSTALLER_URL="https://gitee.com/WeBankPartners/delivery-by-terraform/archive/refs/heads/aws.zip"
  INSTALLER_SOURCE_CODE_DIR="$WECUBE_HOME/delivery-by-terraform-aws/installer"
fi

echo -e "\nFetching WeCube installer from \"$INSTALLER_URL\"..."
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

# replace yum repo
sed -i s/mirror.centos.org/vault.centos.org/g /etc/yum.repos.d/*.repo
sed -i s/^#.*baseurl=http/baseurl=http/g /etc/yum.repos.d/*.repo
sed -i s/^mirrorlist=http/#mirrorlist=http/g /etc/yum.repos.d/*.repo
rm -f /etc/yum.repos.d/epel.repo

# install yum packages
yum remove mysql-community-libs -y
yum install epel-release vim tar unzip jq iptables-services mysql -y

# change ssh config
sed -i 's/#PermitRootLogin yes/PermitRootLogin yes/g' /etc/ssh/sshd_config 
sed -i 's/#PermitRootLogin forced-commands-only/PermitRootLogin yes/g' /etc/ssh/sshd_config 
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
systemctl restart sshd

# replace latest release version
if [ "$WECUBE_RELEASE_VERSION" == "latest" ]; then
  WECUBE_RELEASE_VERSION=$(curl -s https://api.github.com/repos/WeBankPartners/wecube-platform/releases/latest | jq -r '.tag_name')
  echo "Latest release version is ${WECUBE_RELEASE_VERSION}"
fi

unzip -o -q $INSTALLER_PKG -d $WECUBE_HOME
cp -R $INSTALLER_SOURCE_CODE_DIR $WECUBE_HOME

[ -f $WECUBE_RELEASE_VERSION ] && \
  cp $WECUBE_RELEASE_VERSION "$INSTALLER_DIR/wecube-platform/" && \
  cp $WECUBE_RELEASE_VERSION "$INSTALLER_DIR/wecube-system-settings/"


echo -e "\nRunning WeCube installer scripts...\n"
pushd $INSTALLER_DIR >/dev/null

read -d '' BASE_ENV <<-EOF || true
	DATE_TIME='$(date --rfc-3339=seconds)'
	HOST_PRIVATE_IP='${INSTALL_TARGET_HOST}'
	WECUBE_RELEASE_VERSION='${WECUBE_RELEASE_VERSION}'
	WECUBE_SETTINGS='${WECUBE_SETTINGS}'
	WECUBE_HOME='${WECUBE_HOME}'
	WECUBE_USER='${WECUBE_USER}'
	INITIAL_PASSWORD='${INITIAL_PASSWORD}'
	USE_MIRROR_IN_MAINLAND_CHINA='${USE_MIRROR_IN_MAINLAND_CHINA}'
EOF

INSTALLATION_PARAMS_ENV_FILE="$INSTALLER_DIR/installation-params.env"
(umask 066 && cat <<-EOF >"$INSTALLATION_PARAMS_ENV_FILE"
	${BASE_ENV}
EOF
)
./invoke-installer.sh "$INSTALLATION_PARAMS_ENV_FILE" params-validator

PROVISIONING_ENV_FILE="$INSTALLER_DIR/provisioning.env"
(umask 066 && cat <<-EOF >"$PROVISIONING_ENV_FILE"
	${BASE_ENV}

	DOCKER_PORT=2375

	S3_PORT=9000
	S3_ACCESS_KEY=access_key
	S3_SECRET_KEY=secret_key

	MYSQL_PORT=3307
	MYSQL_USERNAME=root
	MYSQL_PASSWORD='${INITIAL_PASSWORD}'
EOF
)
./invoke-installer.sh "$PROVISIONING_ENV_FILE" wecube-user docker

# download s3 docker image and load image
./curl-with-retry.sh -fL "https://wecube-package.s3.ap-southeast-1.amazonaws.com/${WECUBE_RELEASE_VERSION}/minio.tar" -o /tmp/minio.tar
./curl-with-retry.sh -fL "https://wecube-package.s3.ap-southeast-1.amazonaws.com/${WECUBE_RELEASE_VERSION}/mysql.tar" -o /tmp/mysql.tar
./curl-with-retry.sh -fL "https://wecube-package.s3.ap-southeast-1.amazonaws.com/${WECUBE_RELEASE_VERSION}/platform.zip" -o /tmp/platform.zip
unzip -o /tmp/platform.zip -d /tmp/platform
docker load --input /tmp/minio.tar
docker load --input /tmp/mysql.tar
find /tmp/platform/platform/ -name "*.tar" -exec docker load --input {} \;
./invoke-installer.sh "$PROVISIONING_ENV_FILE" mysql-docker minio-docker open-monitor-agent

WECUBE_DB_ENV_FILE="$INSTALLER_DIR/db-deployment-wecube-db-standalone.env"
(umask 066 && cat <<-EOF >"$WECUBE_DB_ENV_FILE"
	${BASE_ENV}

	DB_HOST='${INSTALL_TARGET_HOST}'
	DB_PORT=3307
	DB_NAME=wecube
	DB_USERNAME=root
	DB_PASSWORD='${INITIAL_PASSWORD}'
	WECUBE_RELEASE_VERSION='${WECUBE_RELEASE_VERSION}'
EOF
)
./invoke-installer.sh "$WECUBE_DB_ENV_FILE" db-connectivity

AUTH_SERVER_DB_ENV_FILE="$INSTALLER_DIR/db-deployment-auth-server-db-standalone.env"
(umask 066 && cat <<-EOF >"$AUTH_SERVER_DB_ENV_FILE"
	${BASE_ENV}

	DB_HOST='${INSTALL_TARGET_HOST}'
	DB_PORT=3307
	DB_NAME=auth_server
	DB_USERNAME=root
	DB_PASSWORD='${INITIAL_PASSWORD}'
EOF
)
./invoke-installer.sh "$AUTH_SERVER_DB_ENV_FILE" db-connectivity

WECUBE_PLATFORM_ENV_FILE="$INSTALLER_DIR/app-deployment-wecube-platform-standalone.env"
(umask 066 && cat <<-EOF >"$WECUBE_PLATFORM_ENV_FILE"
	${BASE_ENV}

	STATIC_RESOURCE_HOSTS='${INSTALL_TARGET_HOST}'
	S3_HOST='${INSTALL_TARGET_HOST}'

	CORE_DB_HOST='${INSTALL_TARGET_HOST}'
	CORE_DB_PORT=3307
	CORE_DB_NAME=wecube
	CORE_DB_USERNAME=root
	CORE_DB_PASSWORD='${INITIAL_PASSWORD}'

	AUTH_SERVER_DB_HOST='${INSTALL_TARGET_HOST}'
	AUTH_SERVER_DB_PORT=3307
	AUTH_SERVER_DB_NAME=auth_server
	AUTH_SERVER_DB_USERNAME=root
	AUTH_SERVER_DB_PASSWORD='${INITIAL_PASSWORD}'
EOF
)
./invoke-installer.sh "$WECUBE_PLATFORM_ENV_FILE" wecube-platform

WECUBE_PLUGIN_HOSTING_ENV_FILE="$INSTALLER_DIR/app-deployment-wecube-plugin-hosting-standalone.env"
(umask 066 && cat <<-EOF >"$WECUBE_PLUGIN_HOSTING_ENV_FILE"
	${BASE_ENV}

	CORE_HOST='${INSTALL_TARGET_HOST}'
EOF
)
./invoke-installer.sh "$WECUBE_PLUGIN_HOSTING_ENV_FILE" wecube-plugin-hosting

WECUBE_SYSTEM_SETTINGS_ENV_FILE="$INSTALLER_DIR/app-deployment-wecube-system-settings-standalone.env"
(umask 066 && cat <<-EOF >"$WECUBE_SYSTEM_SETTINGS_ENV_FILE"
	${BASE_ENV}

	S3_ACCESS_KEY=access_key
	S3_SECRET_KEY=secret_key
	AGENT_S3_BUCKET_NAME=wecube-agent
	ARTIFACTS_S3_BUCKET_NAME=wecube-artifacts

	CORE_HOST='${INSTALL_TARGET_HOST}'
	S3_HOST='${INSTALL_TARGET_HOST}'
	PLUGIN_HOST='${INSTALL_TARGET_HOST}'
	PORTAL_ENTRYPOINT='${INSTALL_TARGET_HOST}'
	GATEWAY_ENTRYPOINT='${INSTALL_TARGET_HOST}'

	CORE_DB_HOST='${INSTALL_TARGET_HOST}'
	CORE_DB_PORT=3307
	CORE_DB_NAME=wecube
	CORE_DB_USERNAME=root
	CORE_DB_PASSWORD='${INITIAL_PASSWORD}'

	AUTH_SERVER_DB_HOST='${INSTALL_TARGET_HOST}'
	AUTH_SERVER_DB_PORT=3307
	AUTH_SERVER_DB_NAME=auth_server
	AUTH_SERVER_DB_USERNAME=root
	AUTH_SERVER_DB_PASSWORD='${INITIAL_PASSWORD}'

	PLUGIN_DB_HOST='${INSTALL_TARGET_HOST}'
	PLUGIN_DB_PORT=3307
	PLUGIN_DB_NAME=mysql
	PLUGIN_DB_USERNAME=root
	PLUGIN_DB_PASSWORD='${INITIAL_PASSWORD}'
EOF
)
./invoke-installer.sh "$WECUBE_SYSTEM_SETTINGS_ENV_FILE" wecube-system-settings

popd >/dev/null

ELAPSED_TIME="$((${SECONDS}/60))m$((${SECONDS}%60))s"
echo -e "\n\n\e[0;32mWeCube installation completed in ${ELAPSED_TIME}.\e[0m"
echo -e "\n\e[0;32mPlease visit WeCube at http://${INSTALL_TARGET_HOST}:19090\e[0m\n"
