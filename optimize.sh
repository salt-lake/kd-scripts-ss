#! /bin/bash
#

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin;
export PATH


# set BBR kernel parameters in sysctl.conf and hot load them
check_BBR() {
    if ! grep '^net.ipv4.tcp_congestion_control=bbr' /etc/sysctl.conf; then
        echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
        echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
        sysctl -p
    fi
}

# enable tcp fast open( May increase the risk of being discovered and unstable ),deprecated
# enable_tfo() {
    # if ! grep '^net.ipv4.tcp_fastopen = 3' /etc/sysctl.conf; then
        # echo "net.ipv4.tcp_fastopen = 3" >> /etc/sysctl.conf
        # sysctl -p
    # fi
# }    

# set iptable rules at startup
restore_iptables() {

    echo "@reboot /sbin/iptables-restore /etc/iptables/rules.v4" | crontab -u root -
}

start_ss() {

    # start ss
    # if ! ps aux | grep ss-server | grep -v grep; then
        # supervisorctl reload
    # fi
    supervisorctl reload
}
    
check_BBR
# enable_tfo
restore_iptables
start_ss