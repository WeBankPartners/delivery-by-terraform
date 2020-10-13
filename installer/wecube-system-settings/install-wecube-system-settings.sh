#!/bin/bash

set -e

ENV_FILE=$1
source $ENV_FILE

SYS_SETTINGS_ENV_TEMPLATE_FILE="./wecube-system-settings.env.tpl"
SYS_SETTINGS_ENV_FILE="./wecube-system-settings.env"
../substitute-in-file.sh $ENV_FILE $SYS_SETTINGS_ENV_TEMPLATE_FILE $SYS_SETTINGS_ENV_FILE
cat $ENV_FILE >>$SYS_SETTINGS_ENV_FILE
source $SYS_SETTINGS_ENV_FILE

echo -e "\nUpdating WeCube system settings..."
./update-resource-settings.sh $SYS_SETTINGS_ENV_FILE

[ "$SHOULD_INSTALL_PLUGINS" != "true" ] && echo "Skipped installation of plugins as requested." && exit 0


echo -e "\nDetermine plugin versions to be installed..."

if [ -f "$WECUBE_RELEASE_VERSION" ]; then
	VERSION_SPEC_FILE="$WECUBE_RELEASE_VERSION"
	echo "Reading customized WeCube version specs from file $VERSION_SPEC_FILE"
	PATH="$PATH:." source $VERSION_SPEC_FILE
	PATH="$PATH:." cat $VERSION_SPEC_FILE | tee -a $SYS_SETTINGS_ENV_FILE
else
	if [ "$WECUBE_RELEASE_VERSION" != 'latest' ]; then
		WECUBE_RELEASE_VERSION="tags/$WECUBE_RELEASE_VERSION"
	fi
	GITHUB_RELEASE_URL="https://api.github.com/repos/WeBankPartners/wecube-platform/releases/$WECUBE_RELEASE_VERSION"
	GITHUB_RELEASE_INFO_FILE="$WECUBE_HOME/installer/release-info"
	echo "Fetching release \"$WECUBE_RELEASE_VERSION\" from $GITHUB_RELEASE_URL"
	../curl-with-retry.sh -fL $GITHUB_RELEASE_URL -o $GITHUB_RELEASE_INFO_FILE

	if [ "$WECUBE_FEATURE_SET" == '*' ]; then
		echo "Will install all plugins and best practices as requested."
	else
		FEATURE_SET_URL="https://raw.githubusercontent.com/WeBankPartners/wecube-best-practice/master/feature-sets/$WECUBE_FEATURE_SET"
		FEATURE_SET_FILE="$WECUBE_HOME/installer/feature-set"
		echo "Using feature set \"$WECUBE_FEATURE_SET\" from $FEATURE_SET_URL"
		../curl-with-retry.sh -fL $FEATURE_SET_URL -o $FEATURE_SET_FILE
		source $FEATURE_SET_FILE
		cat $FEATURE_SET_FILE | tee -a $SYS_SETTINGS_ENV_FILE
	fi

	PLUGIN_PKGS=()
	COMPONENT_TABLE_MD=$(cat $GITHUB_RELEASE_INFO_FILE | grep -o '|[ ]*wecube image[ ]*|.*|\\r\\n' | sed -e 's/[ ]*|[ ]*/|/g')
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
			continue
		elif [ -n "$COMPONENT_NAME" ] && ( \
			[ "$WECUBE_FEATURE_SET" == '*' ] || [ "$PLUGINS" != "${PLUGINS/$COMPONENT_NAME/}" ] \
			); then
			PLUGIN_PKGS+=("$COMPONENT_LINK")
		fi
	done

	PLUGIN_CONFIG_PKG=""
	[ "$WECUBE_FEATURE_SET" == '*' ] && PLUGIN_CONFIG='标准安装配置'
	if [ -n "$PLUGIN_CONFIG" ]; then
		PLUGIN_CONFIG_PKG=$(cat $GITHUB_RELEASE_INFO_FILE | grep -o "\\[${PLUGIN_CONFIG}\\]([^()]*)" | cut -f 2 -d '(' | cut -f 1 -d ')')
		echo "Using plugin config \"$PLUGIN_CONFIG\" at $PLUGIN_CONFIG_PKG"
	fi

	cat <<-EOF >>"$SYS_SETTINGS_ENV_FILE"
		PLUGINS="${PLUGINS}"
		PLUGIN_PKGS=(${PLUGIN_PKGS[@]})
		PLUGIN_CONFIG="${PLUGIN_CONFIG}"
		PLUGIN_CONFIG_PKG="${PLUGIN_CONFIG_PKG}"
	EOF
fi

[ ${#PLUGIN_PKGS[@]} == 0 ] && echo -e "\n\e[0;31mFailed to fetch component versions! Installation aborted.\e[0m\n" && exit 1

echo -e "\nInstalling the following WeCube plugin..."
printf '  %s\n' "${PLUGIN_PKGS[@]}"
./configure-plugins.sh $SYS_SETTINGS_ENV_FILE
