#!/bin/bash

set -e

ENV_FILE=$1
source $ENV_FILE

MONITOR_AGENT_URL="https://wecube-1259801214.cos.ap-guangzhou.myqcloud.com/monitor_agent/node_exporter.tar.gz"
MONITOR_AGENT_PKG_FILE="./node_exporter.tar.gz"
MONITOR_AGENT_PORT=9100
echo "Fetching agent package from $MONITOR_AGENT_URL"
../curl-with-retry.sh -fL $MONITOR_AGENT_URL -o $MONITOR_AGENT_PKG_FILE
tar xzf $MONITOR_AGENT_PKG_FILE

echo "Installing agent..."
pushd "./node_exporter" >/dev/null
sudo sh ./start.sh
popd >/dev/null

../wait-for-it.sh -t 120 "$HOST_PRIVATE_IP:$MONITOR_AGENT_PORT" -- echo "Agent is ready."
