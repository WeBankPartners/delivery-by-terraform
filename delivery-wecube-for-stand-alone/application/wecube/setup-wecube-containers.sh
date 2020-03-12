install_target_host=$1
mysql_password=$2
wecube_version=$3
wecube_home=${4:-/data/wecube}

mkdir -p $wecube_home/plugin

echo "Starting wecube database ..."
cp wecube-db.tpl wecube-db.yml
sed -i "s~{{WECUBE_HOME}}~$wecube_home~g" wecube-db.yml
sed -i "s~{{MYSQL_USER_PASSWORD}}~$mysql_password~g" wecube-db.yml
docker-compose -f wecube-db.yml up -d
sleep 120

echo "Starting wecube platform ..."
sed -i "s~{{WECUBE_HOME}}~$wecube_home~g" wecube.cfg
sed -i "s~{{SINGLE_HOST}}~$install_target_host~g" wecube.cfg
sed -i "s~{{SINGLE_PASSWORD}}~$mysql_password~g" wecube.cfg
./deploy_generate_compose.sh wecube.cfg ${wecube_version}
docker-compose -f docker-compose.yml up -d
