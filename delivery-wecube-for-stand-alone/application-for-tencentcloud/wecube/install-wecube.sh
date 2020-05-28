#!/bin/sh

yum install unzip -y
install_target_host=$1
mysql_password=$2
wecube_version=$3
wecube_home=${4:-/data/wecube}
INSTALLER_DIR="$wecube_home/installer"
is_install_plugins=${5:-Y}

# 移除已安装的旧版本Docker
yum remove docker \
           docker-client \
           docker-client-latest \
           docker-common \
           docker-latest \
           docker-latest-logrotate \
           docker-logrotate \
           docker-engine

# 安装Docker
yum install -y yum-utils device-mapper-persistent-data lvm2
#yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
yum install -y docker-ce docker-ce-cli containerd.io

# 安装Docker Compose
curl -L --fail https://github.com/docker/compose/releases/download/1.25.4/run.sh -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# 配置Docker Engine以监听远程API请求
# 我们在这里启用了腾讯云的Docker Hub镜像为中国大陆境内的访问进行加速，请根据您自己的实际情况进行调整
mkdir -p /etc/systemd/system/docker.service.d
cat <<EOF >/etc/systemd/system/docker.service.d/docker-wecube-override.conf
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -H fd:// -H tcp://0.0.0.0:2375 --registry-mirror=https://mirror.ccs.tencentyun.com
EOF

# 启动Docker服务
systemctl enable docker.service
systemctl start docker.service

# 启用IP转发并配置桥接来解决Docker容器对外部网络的通信问题
cat <<EOF >/etc/sysctl.d/zzz.net-forward-and-bridge-for-docker.conf
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl -p /etc/sysctl.d/zzz.net-forward-and-bridge-for-docker.conf

echo -e "Checking Docker...\n"
docker version || (echo 'Docker Engine is not installed!' && exit 1)
docker-compose version || (echo 'Docker Compose is not installed!' && exit 1)
curl -sSlf http://127.0.0.1:2375/version || (echo 'Docker Engine is not listening on TCP port 2375!' && exit 1)
echo -e "\nCongratulations, Docker is properly installed.\n"

GITHUB_RELEASE_URL="https://api.github.com/repos/WeBankPartners/wecube-platform/releases/$wecube_version"
GITHUB_RELEASE_JSON=""
RETRIES=30
echo -e "\nFetching release info for $wecube_version from $GITHUB_RELEASE_URL..."
while [ $RETRIES -gt 0 ] && [ -z "$GITHUB_RELEASE_JSON" ]; do
    RETRIES=$((RETRIES - 1))
    GITHUB_RELEASE_JSON=$(curl -sSfl "$GITHUB_RELEASE_URL")
    if [ -z "$GITHUB_RELEASE_JSON" ]; then
        echo "Retry in 1 second..."
        sleep 1
    else
        break
    fi
done
[ -z "$GITHUB_RELEASE_JSON" ] && echo -e "\nFailed to fetch release info from $GITHUB_RELEASE_URL\nInstallation aborted." && exit 1

RELEASE_TAG_NAME=$(grep -o '"tag_name":[ ]*"[^"]*"' <<< "$GITHUB_RELEASE_JSON" | grep -o 'v[[:digit:]\.]*')
[ -z "$RELEASE_TAG_NAME" ] && echo -e "\nFailed to fetch release tag name!\Installation aborted." && exit 1
echo "wecube_release_tag_name=$RELEASE_TAG_NAME"

wecube_image_version="$wecube_version"
PLUGIN_PKGS=()
COMPONENT_TABLE_MD=$(grep -o '|[ ]*wecube image[ ]*|.*|\\r\\n' <<< "$GITHUB_RELEASE_JSON" | sed -e 's/[ ]*|[ ]*/|/g')
while [[ $COMPONENT_TABLE_MD ]]; do
    COMPONENT=${COMPONENT_TABLE_MD%%"\r\n"*}
    COMPONENT_TABLE_MD=${COMPONENT_TABLE_MD#*"\r\n"}

    COMPONENT=${COMPONENT#"|"}
    COMPONENT_NAME=${COMPONENT%%"|"*}

    COMPONENT=${COMPONENT#*"|"}
    COMPONENT_VERSION=${COMPONENT%%"|"*}

    if [ "$COMPONENT_NAME" == 'wecube image' ]; then
        wecube_image_version="$COMPONENT_VERSION"
    elif [ "$COMPONENT_NAME" ]; then
        PLUGIN_PKGS+=("$COMPONENT_NAME-$COMPONENT_VERSION.zip")
    fi
done
echo "wecube_image_version=$wecube_image_version"

./setup-wecube-containers.sh $install_target_host $mysql_password $wecube_image_version $wecube_home

if [ ${is_install_plugins} != "Y" ];then
  exit;
fi

echo "wecube_plugins=(${PLUGIN_PKGS[@]})"
[ ${#PLUGIN_PKGS[@]} == 0 ] && echo -e "\nFailed to fetch component versions from $GITHUB_RELEASE_URL\nInstallation aborted." && exit 1

echo -e "\nNow starting to configure plugins...\n"
PLUGIN_INSTALLER_URL="https://github.com/WeBankPartners/wecube-auto/archive/master.zip"
PLUGINS_BUCKET_URL="https://wecube-1259801214.cos.ap-guangzhou.myqcloud.com"

PLUGIN_INSTALLER_PKG="$INSTALLER_DIR/wecube-plugin-installer.zip"
PLUGIN_INSTALLER_DIR="$INSTALLER_DIR/wecube-plugin-installer"
mkdir -p "$PLUGIN_INSTALLER_DIR"
echo "Fetching wecube-plugin-installer from $PLUGIN_INSTALLER_URL"
curl -#L $PLUGIN_INSTALLER_URL -o $PLUGIN_INSTALLER_PKG
unzip -o -q $PLUGIN_INSTALLER_PKG -d $PLUGIN_INSTALLER_DIR

echo -e "\nFetching plugin packages...."
PLUGIN_PKG_DIR="$PLUGIN_INSTALLER_DIR/plugins"
mkdir -p "$PLUGIN_PKG_DIR"
PLUGIN_LIST_CSV="$PLUGIN_PKG_DIR/plugin-list.csv"
echo "plugin_package_path" > $PLUGIN_LIST_CSV
for PLUGIN_PKG in "${PLUGIN_PKGS[@]}"; do
    PLUGIN_URL="$PLUGINS_BUCKET_URL/$RELEASE_TAG_NAME/$PLUGIN_PKG"
    PLUGIN_PKG_FILE="$PLUGIN_PKG_DIR/$PLUGIN_PKG"
    echo -e "\nFetching from $PLUGIN_URL"
    curl -L $PLUGIN_URL -o $PLUGIN_PKG_FILE
    echo $PLUGIN_PKG_FILE >> $PLUGIN_LIST_CSV
done

echo -e "\nRegistering WeCube all plugin services ..."
./execute_sql_script_file.sh $install_target_host 3307 wecube root $mysql_password "$INSTALLER_DIR/wecube/database/platform-core/04.update_sys_var_for_deployment.sql"

./configure-plugins.sh $install_target_host "$PLUGIN_INSTALLER_DIR/wecube-auto-master" $PLUGIN_PKG_DIR $mysql_password

echo -e "\nRegistering CMDB asset Ids..."
./execute_sql_script_file.sh $install_target_host 3307 wecmdb_embedded root $mysql_password "$INSTALLER_DIR/wecube/database/cmdb/01.register_cmdb_asset_ids.sql"
