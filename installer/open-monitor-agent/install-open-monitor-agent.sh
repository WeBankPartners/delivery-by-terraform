#!/bin/bash

set -e

ENV_FILE=$1
source $ENV_FILE

echo "Installing open-monitor-agent on $HOST_PRIVATE_IP..."

MONITOR_AGENT_URL="https://wecube-1259801214.cos.ap-guangzhou.myqcloud.com/monitor_agent/node_exporter_v2.1.tar.gz"
MONITOR_AGENT_PKG_FILE="./node_exporter_v2.1.tar.gz"
MONITOR_AGENT_PORT=9100
echo "Fetching agent package from MONITOR_AGENT_URL"
../curl-with-retry.sh -fL $MONITOR_AGENT_URL -o $MONITOR_AGENT_PKG_FILE
tar xzf $MONITOR_AGENT_PKG_FILE

echo "Installing agent..."
pushd "./node_exporter_v2.1" >/dev/null
sh ./start.sh
popd >/dev/null
../wait-for-it.sh -t 120 "$HOST_PRIVATE_IP:$MONITOR_AGENT_PORT" -- echo "Agent is ready."

echo "Installation of open-monitor-agent completed."
