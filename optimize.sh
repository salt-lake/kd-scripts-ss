#! /bin/bash
#

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin;
export PATH

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