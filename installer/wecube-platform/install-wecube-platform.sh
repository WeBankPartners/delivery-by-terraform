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
		echo 'Using Gitee as mirror for WeCube release in Mainland China.'
		RELEASE_URL="https://gitee.com/api/v5/repos/WeBankPartners/wecube-platform/releases/$WECUBE_RELEASE_VERSION"
	fi

	RELEASE_INFO_FILE="$WECUBE_HOME/installer/release-info"
	echo "Fetching release $WECUBE_RELEASE_VERSION from $RELEASE_URL"
	../curl-with-retry.sh -fL $RELEASE_URL -o $RELEASE_INFO_FILE

	WECUBE_IMAGE_VERSION=""
	PLUGIN_PKGS=()
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

[ -z "$WECUBE_IMAGE_VERSION" ] && echo -e "\n\e[0;31mFailed to determine WeCube image version! Installation aborted.\e[0m\n" && exit 1

echo -e "\nInstalling WeCube platform with image version $WECUBE_IMAGE_VERSION"
./setup-wecube-containers.sh $ENV_FILE $WECUBE_IMAGE_VERSION

echo "Installation of wecube-platform completed."
