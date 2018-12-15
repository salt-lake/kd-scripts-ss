#!/bin/bash
# init the ss hosts when created

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin;
export PATH

# enable ipv4 precedence
if ! grep '^precedence ::ffff:0:0/96  100' /etc/gai.conf; then
    echo 'precedence ::ffff:0:0/96  100' >> /etc/gai.conf
fi

# install git
function check_git(){
  if ! [ -x "$(command -v git)" ]; then
    apt update
    apt install -y git
  fi
}

# git pull ss
function check_scripts(){
  if [ ! -d "/home/kd-scripts-ss" ]; then
    cd /home
    git clone https://github.com/Mooc1988/kd-scripts-ss.git
  else
    cd /home/kd-scripts-ss
    git pull
  fi
}


check_git
check_scripts
bash /home/kd-scripts-ss/deploy.sh

# start ss
if ! ps aux | grep ss-server | grep -v grep; then
    supervisorctl reload
fi

# set BBR kernel parameters in sysctl.conf and hot load them
function check_BBR {
    if ! grep '^net.ipv4.tcp_congestion_control=bbr' /etc/sysctl.conf; then
        echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
        echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
        sysctl -p
    fi
}

check_BBR