#!/bin/bash
#

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin;
export PATH

function install_ss(){
    if ! [ -x "$(command -v ss-server)" ]; then
        if grep -Eqi "16.04" /etc/issue ; then
          apt-get install software-properties-common -y
          add-apt-repository ppa:max-c-lv/shadowsocks-libev -y
        fi
        apt-get update
        apt install shadowsocks-libev -y
    fi
    if [ ! -d "/etc/shadowsocks-libev" ];then
      mkdir /etc/shadowsocks-libev
    fi
    cp /home/kd-scripts-ss/config/ss-libev/*  /etc/shadowsocks-libev
}

function install_supervisor(){
    if ! [ -x "$(command -v supervisorctl)" ]; then
        apt update
        apt install supervisor -y
    fi
    if [ ! -f "/etc/supervisor/conf.d/ss.conf" ]; then
      cp /home/kd-scripts-ss/config/ss.conf /etc/supervisor/conf.d/ss.conf
    fi
}

configure_ss() {

    cp /home/kd-scripts-ss/config/shadowsocks-libev /etc/default/shadowsocks-libev
    adduser --system --disabled-password --disabled-login --no-create-home shadowsocks
    cp /home/kd-scripts-ss/config/local.conf /etc/sysctl.d/local.conf
    sysctl --system
    
}

function config_iptables(){
    if [ ! -f "/etc/iptables/rules.v4" ]; then
        mkdir -p /etc/iptables
        cp /home/kd-scripts-ss/config/rules.v4 /etc/iptables/rules.v4
    fi
    iptables-restore /etc/iptables/rules.v4
}


function install(){

    install_ss
    install_supervisor
    configure_ss
    config_iptables
   
}

install

