install_target_host=$1
docker_registry_password=$2
mysql_password=$3
wecube_version=$4

yum install git -y
yum install docker -y
yum install docker-compose -y

echo "OPTIONS=-H unix:///var/run/docker.sock -H tcp://0.0.0.0:2375" >> /etc/sysconfig/docker

systemctl start docker.service
systemctl enable docker.service

mkdir -p /data/wecube/plugin
sed "s~{{MYSQL_USER_PASSWORD}}~$mysql_password~g" wecube-db.tpl > wecube-db.yml
echo "Starting wecube database ..."
docker-compose -f wecube-db.yml up -d
sleep 120

echo "Starting wecube platform ..."
sed -i "s~{{SINGLE_HOST}}~$install_target_host~g" wecube.cfg
sed -i "s~{{SINGLE_PASSWORD}}~$mysql_password~g" wecube.cfg
./deploy_generate_compose.sh wecube.cfg ${wecube_version}
docker-compose -f docker-compose.yml up -d

echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf 
echo "net.bridge.bridge-nf-call-ip6tables = 1" >> /etc/sysctl.conf 
echo "net.bridge.bridge-nf-call-iptables = 1" >> /etc/sysctl.conf 
sysctl -p 
