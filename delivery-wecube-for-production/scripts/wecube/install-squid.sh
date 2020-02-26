#!/bin/bash

echo "Starting squid ..."

yum install squid -y
#docker run --name squid -d --restart=always --publish 3128:3128 --volume /srv/docker/squid/cache:/var/spool/squid3 sameersbn/squid

echo "Start squid success !"