#!/bin/bash

set -e

ENV_FILE=$1
source $ENV_FILE

[ -f "$WECUBE_RELEASE_VERSION" ] && USE_CUSTOMIZED_VERSION_SPEC='true' || USE_CUSTOMIZED_VERSION_SPEC=''

SYS_SETTINGS_ENV_TEMPLATE_FILE="./wecube-system-settings.env.tpl"
SYS_SETTINGS_ENV_FILE="./wecube-system-settings.env"
echo -e "\nBuilding WeCube system settings env file $SYS_SETTINGS_ENV_FILE"
../substitute-in-file.sh $ENV_FILE $SYS_SETTINGS_ENV_TEMPLATE_FILE $SYS_SETTINGS_ENV_FILE
cat $ENV_FILE >>$SYS_SETTINGS_ENV_FILE


if [ "$USE_CUSTOMIZED_VERSION_SPEC" == 'true' ]; then
	CUSTOMIZED_VERSION_SPEC_FILE="$WECUBE_RELEASE_VERSION"
	echo -e "\nUsing customized WeCube version specs from file \"$CUSTOMIZED_VERSION_SPEC_FILE\""
	PATH="$PATH:." source $CUSTOMIZED_VERSION_SPEC_FILE
else
	if [ "$WECUBE_RELEASE_VERSION" != 'latest' ]; then
		WECUBE_RELEASE_VERSION="tags/$WECUBE_RELEASE_VERSION"
	fi
	RELEASE_URL="https://api.github.com/repos/WeBankPartners/wecube-platform/releases/$WECUBE_RELEASE_VERSION"
	if [ "$USE_MIRROR_IN_MAINLAND_CHINA" == "true" ]; then
		echo 'Using Gitee as mirror for WeCube release in Mainland China https://gitee.com/api/v5/repos/WeBankPartners/wecube-platform/'
		RELEASE_URL="https://gitee.com/api/v5/repos/WeBankPartners/wecube-platform/releases/$WECUBE_RELEASE_VERSION"
	fi
	RELEASE_INFO_FILE="$WECUBE_HOME/installer/release-info"
	echo -e "\nFetching release info \"$WECUBE_RELEASE_VERSION\" from $RELEASE_URL\n"
	../curl-with-retry.sh -fL $RELEASE_URL -o $RELEASE_INFO_FILE

	echo -e "\nUsing WeCube settings \"$WECUBE_SETTINGS\""
	source "./settings/${WECUBE_SETTINGS}.sh"

	echo -e "\nLocating plugin packages...\n"
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
			continue
		elif [ -n "$COMPONENT_NAME" ]; then
			if [ "$PLUGIN_NAMES" == '*' ] || [ "${PLUGIN_NAMES/$COMPONENT_NAME/}" != "$PLUGIN_NAMES" ]; then
				echo "Found plugin package for \"$COMPONENT_NAME\" at $COMPONENT_LINK"
				PLUGIN_PKGS+=("$COMPONENT_LINK")
			fi
		fi
	done

	echo -e "\nLocating plugin config package...\n"
	PLUGIN_CONFIG_PKG=$(cat $RELEASE_INFO_FILE | grep -o "\\[${PLUGIN_CONFIG}\\]([^()]*)" | cut -f 2 -d '(' | cut -f 1 -d ')')
	if [ -n "$PLUGIN_CONFIG_PKG" ]; then
		echo "Using plugin config \"$PLUGIN_CONFIG\" at $PLUGIN_CONFIG_PKG"
	else
		echo "Plugin config package for \"$PLUGIN_CONFIG\" is NOT found."
	fi

	echo -e "\nLocating artifact packages...\n"
	ARTIFACTS_PKGS=()
	for ARTIFACT_NAME in "${ARTIFACTS[@]}"; do
		ARTIFACT_PKG=$(cat $RELEASE_INFO_FILE | grep -o "\\[${ARTIFACT_NAME}\\]([^()]*)" | cut -f 2 -d '(' | cut -f 1 -d ')')

		if [ -n "$ARTIFACT_PKG" ]; then
			echo "Found artifact package for \"$ARTIFACT_NAME\" at $ARTIFACT_PKG"
			ARTIFACTS_PKGS+=("$ARTIFACT_PKG")
		else
			echo "Artifact package for \"$ARTIFACT_NAME\" is NOT found.\n"
			continue
		fi
	done
fi

../substitute-in-file.sh $ENV_FILE "./wecube_import_asset_id.json.tpl" "./wecube_import_asset_id.json"

echo -e "\nAppending the following env vars in file $SYS_SETTINGS_ENV_FILE"
cat <<-EOF | tee -a "$SYS_SETTINGS_ENV_FILE"
	PLUGIN_PKGS=(${PLUGIN_PKGS[@]})
	PLUGIN_CONFIG_PKG='${PLUGIN_CONFIG_PKG}'
	ARTIFACTS_PKGS=(${ARTIFACTS_PKGS[@]})
EOF

echo -e "\nUpdating WeCube system settings...\n"
./update-system-settings.sh $SYS_SETTINGS_ENV_FILE

echo -e "\nConfiguring WeCube plugins...\n"
./configure-plugins.sh $SYS_SETTINGS_ENV_FILE

#echo -e "\nChanging owner of WeCube home \"$WECUBE_HOME\" to \"$USER:$WECUBE_USER\"..."
#sudo chown -R $USER:$WECUBE_USER $WECUBE_HOME
#sudo chmod -R 0770 $WECUBE_HOME
