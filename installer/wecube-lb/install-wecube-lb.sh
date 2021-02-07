#!/bin/bash

set -e

ENV_FILE=$1
source $ENV_FILE

DOCKER_COMPOSE_ENV_TEMPLATE_FILE="./wecube-haproxy.docker-compose.env.template"
DOCKER_COMPOSE_ENV_FILE="./wecube-haproxy.docker-compose.env"
../substitute-in-file.sh $ENV_FILE $DOCKER_COMPOSE_ENV_TEMPLATE_FILE $DOCKER_COMPOSE_ENV_FILE
source $DOCKER_COMPOSE_ENV_FILE


echo -e "\nCreating haproxy directories..."

VOLUME_DIRECTORIES=(
	"${HAPROXY_CONF_DIR}"
	"${HAPROXY_LOG_DIR}"
)
for VOLUME_DIR in "${VOLUME_DIRECTORIES[@]}"; do
	echo "  - ${VOLUME_DIR}"
	mkdir -p $VOLUME_DIR
	sudo chown -R $USER:$WECUBE_USER $VOLUME_DIR
	sudo chmod -R 0770 $VOLUME_DIR
done


HAPROXY_CONF_FILE="$HAPROXY_CONF_DIR/haproxy.cfg"
HAPROXY_HTTP_CHECK_INTERVAL=3s
HAPROXY_HTTP_CHECK_FALL=3
HAPROXY_HTTP_CHECK_RISE=2
echo -e "\nBuilding haproxy configuration file \"$HAPROXY_CONF_FILE\"..."

cat <<-EOF | tee $HAPROXY_CONF_FILE
	global
	    maxconn 256
	    log stdout local0

	defaults
	    mode http
	    timeout connect 5000ms
	    timeout client 50000ms
	    timeout server 50000ms
EOF

GATEWAY_HOSTS=(${GATEWAY_HOSTS//,/ })
GATEWAY_HEALTH_CHECK_URL="/platform/v1/health-check"
cat <<-EOF | tee -a $HAPROXY_CONF_FILE

	frontend platform-gateway
	    bind *:${GATEWAY_PORT}
	    default_backend platform-gateway-servers

	backend platform-gateway-servers
	    option httpchk GET ${GATEWAY_HEALTH_CHECK_URL}
	    default-server inter ${HAPROXY_HTTP_CHECK_INTERVAL} fall ${HAPROXY_HTTP_CHECK_FALL} rise ${HAPROXY_HTTP_CHECK_RISE}
EOF
for INDEX in ${!GATEWAY_HOSTS[@]}; do
	cat <<-EOF | tee -a $HAPROXY_CONF_FILE
	    server platform-gateway-server-$(( ${INDEX} + 1 )) ${GATEWAY_HOSTS[${INDEX}]}:${GATEWAY_PORT} check
	EOF
done

PORTAL_HOSTS=(${PORTAL_HOSTS//,/ })
PORTAL_HEALTH_CHECK_URL="/platform/v1/health-check"
cat <<-EOF | tee -a $HAPROXY_CONF_FILE

	frontend wecube-portal
	    bind *:${PORTAL_PORT}
	    default_backend wecube-portal-servers

	backend wecube-portal-servers
	    option httpchk GET ${PORTAL_HEALTH_CHECK_URL}
	    default-server inter ${HAPROXY_HTTP_CHECK_INTERVAL} fall ${HAPROXY_HTTP_CHECK_FALL} rise ${HAPROXY_HTTP_CHECK_RISE}
EOF
for INDEX in ${!PORTAL_HOSTS[@]}; do
	cat <<-EOF | tee -a $HAPROXY_CONF_FILE
	    server wecube-portal-server-$(( ${INDEX} + 1 )) ${PORTAL_HOSTS[${INDEX}]}:${PORTAL_PORT} check
	EOF
done


echo -e "\nBringing up haproxy container..."
sudo -su $WECUBE_USER docker-compose -f "./wecube-haproxy.yml" --env-file="$DOCKER_COMPOSE_ENV_FILE" up -d


echo -e "\nChecking service port readiness..."
PORTS_TO_CHECK=(
  "$GATEWAY_PORT"
  "$PORTAL_PORT"
)
for PORT_TO_CHECK in "${PORTS_TO_CHECK[@]}"; do
	../wait-for-it.sh -t 120 "$HOST_PRIVATE_IP:$PORT_TO_CHECK" -- echo -e "Service listening at port $PORT_TO_CHECK is ready.\n"
done


echo -e "\nInstalling keepalived..."
#curl http://www.nosuchhost.net/~cheese/fedora/packages/epel-7/x86_64/cheese-release-7-1.noarch.rpm -o cheese-release.rpm
#sudo rpm -Uvh cheese-release.rpm
sudo yum install -y keepalived

KEEPALIVED_CONF_FILE="/etc/keepalived/keepalived.conf"
echo -e "\nBuilding keepalived configuration file \"$KEEPALIVED_CONF_FILE\"..."
cat <<-EOF | sudo tee $KEEPALIVED_CONF_FILE
	global_defs {
	    vrrp_skip_check_adv_addr
	    vrrp_garp_interval 0
	    vrrp_gna_interval 0
	}

	#vrrp_track_process track_dockerd {
	#    process "dockerd"
	#}

	vrrp_instance VI_1 {
	    state ${KEEPALIVED_VRRP_INSTANCE_STATE}
	    interface ${KEEPALIVED_VRRP_INSTANCE_INTERFACE}
	    virtual_router_id 51
	    no_preempt
	    priority ${KEEPALIVED_VRRP_INSTANCE_PRIORITY}
	    advert_int 1
	    
	    authentication {
	        auth_type PASS
	        auth_pass wecubelb
	    }

	    unicast_src_ip ${KEEPALIVED_SRC_IP}
	    unicast_peer {
	        ${KEEPALIVED_PEER_IP}
	    }

	    virtual_ipaddress {
	        ${KEEPALIVED_VIRTUAL_IP}
	    }

	    track_interface {
	        ${KEEPALIVED_VRRP_INSTANCE_INTERFACE}
	    }
	#    track_process {
	#        track_dockerd
	#    }
	}
EOF

SYSCTL_CONF_FILE="/etc/sysctl.d/w02.nonlocal-bind-for-keepalived.conf"
cat <<-EOF | sudo tee $SYSCTL_CONF_FILE >/dev/null
	net.ipv4.ip_nonlocal_bind = 1
EOF
sudo sysctl -p $SYSCTL_CONF_FILE
sudo sysctl net.ipv4.ip_nonlocal_bind

sudo systemctl enable keepalived
sudo systemctl start keepalived
