#!/bin/bash

set -e

ENV_FILE=$1
source $ENV_FILE

echo "Deploying wecube-platform on $HOST_PRIVATE_IP"

if [ -f "$WECUBE_RELEASE_VERSION" ]; then
	echo "Reading customized WeCube version specs from file $WECUBE_RELEASE_VERSION"
	PATH="$PATH:." source "$WECUBE_RELEASE_VERSION"
else
	if [ "$WECUBE_RELEASE_VERSION" != 'latest' ]; then
		WECUBE_RELEASE_VERSION="tags/$WECUBE_RELEASE_VERSION"
	fi

	RELEASE_URL="https://api.github.com/repos/WeBankPartners/wecube-platform/releases/$WECUBE_RELEASE_VERSION"
	if [ "$USE_MIRROR_IN_MAINLAND_CHINA" == "true" ]; then
		echo 'Using Gitee as mirror for WeCube release in Mainland China https://gitee.com/api/v5/'
		RELEASE_URL="https://gitee.com/api/v5/repos/WeBankPartners/wecube-platform/releases/$WECUBE_RELEASE_VERSION"
	fi

	RELEASE_INFO_FILE="$WECUBE_HOME/installer/release-info"
	echo "Fetching release $WECUBE_RELEASE_VERSION from $RELEASE_URL"
	../curl-with-retry.sh -fL $RELEASE_URL -o $RELEASE_INFO_FILE

	WECUBE_IMAGE_VERSION=""
	COMPONENT_TABLE_MD=$(cat $RELEASE_INFO_FILE | grep -o '|[ ]*wecube image[ ]*|.*|\\r\\n' | sed -e 's/[ ]*|[ ]*/|/g')
	while [ -n "$COMPONENT_TABLE_MD" ]; do
		# process row by row
		COMPONENT=${COMPONENT_TABLE_MD%%"\r\n"*}
		COMPONENT_TABLE_MD=${COMPONENT_TABLE_MD#*"\r\n"}
		# take name from 1st column
		COMPONENT=${COMPONENT#"|"}
		COMPONENT_NAME=${COMPONENT%%"|"*}
		# take version from 2nd column
		COMPONENT=${COMPONENT#*"|"}
		COMPONENT_VERSION=${COMPONENT%%"|"*}
		# take download link from 3rd column
		COMPONENT=${COMPONENT#*"|"}
		COMPONENT_LINK=${COMPONENT%%"|"*}

		if [ "$COMPONENT_NAME" == 'wecube image' ]; then
			WECUBE_IMAGE_VERSION="$COMPONENT_VERSION"
			break;
		fi
	done
fi

if [ -z "$WECUBE_IMAGE_VERSION" ]; then
	echo -e "\n\e[0;31mFailed to determine WeCube image version! Installation aborted.\e[0m\n"
	exit 1
fi

WECUBE_ENV_TEMPLATE_FILE="./wecube-platform.env.tpl"
WECUBE_ENV_FILE="./wecube-platform.env"
echo "Building WeCube platform env file $WECUBE_ENV_FILE"
STATIC_RESOURCE_SERVER_USER=${WECUBE_USER}
STATIC_RESOURCE_SERVER_PASSWORD=${INITIAL_PASSWORD}
STATIC_RESOURCE_SERVER_PORT="22"
STATIC_RESOURCE_SERVER_PATH="${WECUBE_HOME}/data/wecube-portal/ui-resources"
if [[ $STATIC_RESOURCE_HOSTS =~ "," ]]
then
    echo "multiple static server check"
    STATIC_RESOURCE_SERVER_USER="${STATIC_RESOURCE_SERVER_USER},${STATIC_RESOURCE_SERVER_USER}"
    STATIC_RESOURCE_SERVER_PASSWORD="${STATIC_RESOURCE_SERVER_PASSWORD},${STATIC_RESOURCE_SERVER_PASSWORD}"
    STATIC_RESOURCE_SERVER_PORT="${STATIC_RESOURCE_SERVER_PORT},${STATIC_RESOURCE_SERVER_PORT}"
    STATIC_RESOURCE_SERVER_PATH="${STATIC_RESOURCE_SERVER_PATH},${STATIC_RESOURCE_SERVER_PATH}"
fi

eval "cat >$WECUBE_ENV_FILE <<EOF
$(sed -e 's/`/``/g' $WECUBE_ENV_TEMPLATE_FILE)
EOF
"
#WECUBE_IMAGE_VERSION=$WECUBE_IMAGE_VERSION \
#  ../substitute-in-file.sh $ENV_FILE $WECUBE_ENV_TEMPLATE_FILE $WECUBE_ENV_FILE

echo -e "\nInstalling WeCube platform with image version $WECUBE_IMAGE_VERSION"
./setup-wecube-containers.sh $WECUBE_ENV_FILE

#echo -e "\nChanging owner of WeCube home \"$WECUBE_HOME\" to \"$USER:$WECUBE_USER\"..."
#sudo chown -R $USER:$WECUBE_USER $WECUBE_HOME
#sudo chmod -R 0770 $WECUBE_HOME
mkdir -p $WECUBE_HOME/minio-storage/data/wecube-plugin-package-bucket
mkdir -p $WECUBE_HOME/minio-storage/data/salt-tmp
mkdir -p $WECUBE_HOME/minio-storage/data/taskman-file
mkdir -p $WECUBE_HOME/minio-storage/data/terminal
mkdir -p $WECUBE_HOME/minio-storage/data/wecube-agent
mkdir -p $WECUBE_HOME/minio-storage/data/wecube-artifacts