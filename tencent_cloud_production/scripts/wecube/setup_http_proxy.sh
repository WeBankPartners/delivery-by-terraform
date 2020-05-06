#!/bin/bash
squid_server=$1
squid_port=$2
grep -i "export proxy=http://$squid_server:$squid_port" ~/.bash_profile || sed -i "$ a export proxy=http://$squid_server:$squid_port" ~/.bash_profile;
	source ~/.bash_profile;
	grep -i "export http_proxy=$proxy" ~/.bash_profile || sed -i "$ a export http_proxy=$proxy" ~/.bash_profile;
	grep -i "export https_proxy=$proxy" ~/.bash_profile || sed -i "$ a export https_proxy=$proxy" ~/.bash_profile;
	grep -i "export ftp_proxy=$proxy" ~/.bash_profile || sed -i "$ a export ftp_proxy=$proxy" ~/.bash_profile;
	grep -i "export no_proxy='localhost, 127.0.0.1, ::1'" ~/.bash_profile || sed -i "$ a export no_proxy='localhost, 127.0.0.1, ::1'" ~/.bash_profile;

	grep -i "export proxy=http://$squid_server:$squid_port" ~/.bashrc || sed -i "$ a export proxy=http://$squid_server:$squid_port" ~/.bashrc;
	source ~/.bashrc;
	grep -i "export http_proxy=$proxy" ~/.bashrc || sed -i "$ a export http_proxy=$proxy" ~/.bashrc;
	grep -i "export https_proxy=$proxy" ~/.bashrc || sed -i "$ a export https_proxy=$proxy" ~/.bashrc;
	grep -i "export ftp_proxy=$proxy" ~/.bashrc || sed -i "$ a export ftp_proxy=$proxy" ~/.bashrc;
	grep -i "export no_proxy='localhost, 127.0.0.1, ::1'" ~/.bashrc || sed -i "$ a export no_proxy='localhost, 127.0.0.1, ::1'" ~/.bashrc;

source ~/.bash_profile;
source ~/.bashrc;
