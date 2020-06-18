#!/bin/bash

set -e

SCRIPT_DIR=$(realpath $(dirname "$0"))
ENV_FILE="$1"; shift

source $ENV_FILE

for INSTALLER in "$@"; do
    INSTALLER_DIR="$SCRIPT_DIR/$INSTALLER"
    pushd $INSTALLER_DIR >/dev/null 2>&1

    [ ! -d $INSTALLER_DIR ] && echo -e "\nInvalid installer name $INSTALLER_DIR" && exit 1

    echo -e "\n\e[0;36mInstalling $INSTALLER on host $HOST_PRIVATE_IP with env file $ENV_FILE ...\e[0m\n"
    find . -name '*.sh' -exec chmod +x \{\} +
    source ~/.bashrc
    sh "$INSTALLER_DIR/install-$INSTALLER.sh" "$ENV_FILE"
    echo -e "\n\e[0;32mInstallation of $INSTALLER on host $HOST_PRIVATE_IP completed successfully.\e[0m\n"

    popd >/dev/null 2>&1
done
