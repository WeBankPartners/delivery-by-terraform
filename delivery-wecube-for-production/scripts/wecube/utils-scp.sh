#!/bin/bash

user=$1
remote_ip=$2
passwd=$3
source_file=$4
target=$5

echo "scp ${source_file} ${user}@${remote_ip}:${target}"
expect -c "
spawn scp ${source_file} ${user}@${remote_ip}:${target}
expect {
    \"*assword\" {set timeout 30; send \"${passwd}\r\";}
    \"yes/no\" {send \"yes\r\"; exp_continue;}
 }
expect eof
"