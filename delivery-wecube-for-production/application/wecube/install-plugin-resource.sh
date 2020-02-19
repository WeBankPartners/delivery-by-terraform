s3_host=$1
wecube_host=$1
plugin_host=$1
default_password=$2
wecube_version=$3
mysql_addr=$4
mysql_port=$5
wecube_bucket=$6

yum install git -y
yum install docker -y
yum install docker-compose -y
yum install mysql -y

echo "OPTIONS=-H unix:///var/run/docker.sock -H tcp://0.0.0.0:2375" >> /etc/sysconfig/docker

systemctl start docker.service
systemctl enable docker.service

mkdir -p /data/wecube/plugin
sed "s~{{MYSQL_USER_PASSWORD}}~$default_password~g" wecube-db.tpl > wecube-db.yml
echo "Starting wecube database ..."
docker-compose -f wecube-db.yml up -d
sleep 120

echo "Starting wecube platform ..."
sed -i "s~{{S3_HOST}}~$s3_host~g" wecube.cfg
sed -i "s~{{WECUBE_HOST}}~$wecube_host~g" wecube.cfg
sed -i "s~{{PLUGIN_HOST}}~$plugin_host~g" wecube.cfg

sed -i "s~{{PLUGIN_HOST_PASSWORD}}~$default_password~g" wecube.cfg
sed -i "s~{{STATIC_RESOURCE_SERVER_PASSWORD}}~$default_password~g" wecube.cfg
sed -i "s~{{MYSQL_ADDR}}~$mysql_addr~g" wecube.cfg
sed -i "s~{{MYSQL_PORT}}~$mysql_port~g" wecube.cfg
sed -i "s~{{MYSQL_PASSWORD}}~$default_password~g" wecube.cfg
sed -i "s~{{WECUBE_BUCKET}}~$wecube_bucket~g" wecube.cfg

./deploy_generate_compose.sh wecube.cfg ${wecube_version}
docker-compose -f docker-compose.yml up -d

echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf 
echo "net.bridge.bridge-nf-call-ip6tables = 1" >> /etc/sysctl.conf 
echo "net.bridge.bridge-nf-call-iptables = 1" >> /etc/sysctl.conf 
sysctl -p 
