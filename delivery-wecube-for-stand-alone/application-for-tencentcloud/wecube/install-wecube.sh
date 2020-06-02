#!/bin/bash

install_target_host=$1
mysql_password=$2
wecube_version=$3
wecube_home=${4:-/data/wecube}
should_install_plugins=${5:-Y}

echo -e "Checking Docker...\n"
docker version || (echo 'Docker Engine is not installed!' && exit 1)
docker-compose version || (echo 'Docker Compose is not installed!' && exit 1)
curl -sSLf http://127.0.0.1:2375/version || (echo 'Docker Engine is not listening on TCP port 2375!' && exit 1)
echo -e "\nCongratulations, Docker is properly installed.\n"


echo -e "\nDetermine component versions to be installed...\n"
if [ -f "$wecube_version" ]; then
    echo "Reading customized WeCube version specs from $wecube_version..."
    PATH="$PATH:." source "$wecube_version"
else
  GITHUB_RELEASE_URL="https://api.github.com/repos/WeBankPartners/wecube-platform/releases/$wecube_version"
  GITHUB_RELEASE_JSON=""
  RETRIES=30
  echo "Fetching release info for $wecube_version from $GITHUB_RELEASE_URL..."
  while [ $RETRIES -gt 0 ] && [ -z "$GITHUB_RELEASE_JSON" ]; do
      RETRIES=$((RETRIES - 1))
      GITHUB_RELEASE_JSON=$(curl -sSfl "$GITHUB_RELEASE_URL")
      if [ -z "$GITHUB_RELEASE_JSON" ]; then
          PAUSE=$(( ( RANDOM % 5 ) + 1 ))
          echo "Retry in $PAUSE seconds..."
          sleep "$PAUSE"
      else
          break
      fi
  done
  [ -z "$GITHUB_RELEASE_JSON" ] && echo -e "\nFailed to fetch release info from $GITHUB_RELEASE_URL\nInstallation aborted." && exit 1

  wecube_image_version=""
  PLUGIN_PKGS=()
  COMPONENT_TABLE_MD=$(grep -o '|[ ]*wecube image[ ]*|.*|\\r\\n' <<< "$GITHUB_RELEASE_JSON" | sed -e 's/[ ]*|[ ]*/|/g')
  while [[ $COMPONENT_TABLE_MD ]]; do
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
          wecube_image_version="$COMPONENT_VERSION"
      elif [ -n "$COMPONENT_NAME" ]; then
          PLUGIN_PKGS+=("$COMPONENT_LINK")
      fi
  done
fi

echo "wecube_image_version: $wecube_image_version"
[ -z "$wecube_image_version" ] && echo -e "\nFailed to determine WeCube image version! Installation aborted." && exit 1
if [[ $should_install_plugins =~ ^[Yy]$ ]]; then
  echo "wecube_plugins:"
  printf '  %s\n' "${PLUGIN_PKGS[@]}"
  [ ${#PLUGIN_PKGS[@]} == 0 ] && echo -e "\nFailed to fetch component versions! Installation aborted." && exit 1
fi

echo -e "\nInstalling WeCube with above versions...\n"
CONFIG_FILE="wecube.cfg"
./apply-configurations.sh $CONFIG_FILE $install_target_host $mysql_password $wecube_home
./setup-wecube-containers.sh $CONFIG_FILE $wecube_image_version

[[ ! $should_install_plugins =~ ^[Yy]$ ]] && echo -e "\nSkipped plugin installation as requested.\n" && exit 0;

./configure-plugins.sh $CONFIG_FILE "${PLUGIN_PKGS[@]}"
