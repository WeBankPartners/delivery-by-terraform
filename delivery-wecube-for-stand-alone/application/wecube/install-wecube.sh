yum install git -y
yum install docker -y
yum install docker-compose -y
yum install unzip -y

echo "OPTIONS=-H unix:///var/run/docker.sock -H tcp://0.0.0.0:2375" >> /etc/sysconfig/docker

systemctl enable docker.service
systemctl start docker.service

./setup-wecube-containers.sh $@

echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf 
echo "net.bridge.bridge-nf-call-ip6tables = 1" >> /etc/sysctl.conf 
echo "net.bridge.bridge-nf-call-iptables = 1" >> /etc/sysctl.conf 
sysctl -p 
