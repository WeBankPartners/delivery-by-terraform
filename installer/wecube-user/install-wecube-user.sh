#!/bin/bash

set -e

ENV_FILE=$1
source $ENV_FILE

if [ "$WECUBE_USER" == "root" ]; then
	echo "Using root as WeCube user, no further step is needed."
	exit 0;
fi

echo "Creating user and group \"$WECUBE_USER\"..."
id -u $WECUBE_USER >/dev/null 2>&1 || sudo useradd -U $WECUBE_USER
sudo chpasswd <<<"${WECUBE_USER}:${INITIAL_PASSWORD}"

echo "Adding user \"$USER\" to group \"$WECUBE_USER\""
sudo usermod -aG $WECUBE_USER $USER

echo "Configuring owner and permissions for directory \"$WECUBE_HOME\"..."
sudo chown -R $USER:$WECUBE_USER $WECUBE_HOME
sudo chmod -R 0770 $WECUBE_HOME

echo "Enabling group \"${WECUBE_USER}\" to run all commands using \"sudo\" without password..."
sudo cat <<-EOF | sudo tee "/etc/sudoers.d/zzz-allow-group-${WECUBE_USER}-with-no-password" >/dev/null
	%${WECUBE_USER}        ALL=(ALL)       NOPASSWD: ALL
EOF
