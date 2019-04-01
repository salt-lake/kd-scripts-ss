#!/bin/bash
# calculate by /proc/net/dev

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin;
export PATH

# ethn=`ls /sys/class/net | head -n 1`
ethn=`ifconfig | head -1 | cut -d " " -f1`

net_traffic_statistics() {


    RX=$(cat /proc/net/dev | grep $ethn | sed 's/:/ /g' | awk '{print $2}')
    TX=$(cat /proc/net/dev | grep $ethn | sed 's/:/ /g' | awk '{print $10}')

    TOTAL=$((${RX}+${TX}))

    MIN=`TZ=UTC-8 date +"%Y%m%d%H%M"`
    Last_MIN=`TZ=UTC-8 date +"%Y%m%d%H%M" -d "1 minutes ago"`
    Current_Hour=`TZ=UTC-8 date +"%Y%m%d%H"`
    TODAY=`TZ=UTC-8 date +"%Y%m%d"`

    redis-cli SET total:${MIN} $TOTAL EX 172800

    Last_TOTAL=`redis-cli GET total:${Last_MIN}`

    if [[ $Last_TOTAL ]]; then

        Current_min_traffic=$((${TOTAL}-${Last_TOTAL}))
        redis-cli SET tr:${Last_MIN} $Current_min_traffic EX 172800
        
        
        Hour_Current=`redis-cli GET tr:${Current_Hour}`
        Hour_TOTAL=$((${Hour_Current}+${Current_min_traffic}))
        redis-cli SET tr:${Current_Hour} $Hour_TOTAL EX 172800
        
        Today_Current=`redis-cli GET tr:${TODAY}`
        Today_TOTAL=$((${Today_Current}+${Current_min_traffic}))
        redis-cli SET tr:${TODAY} $Today_TOTAL
        
    fi

}

mem_statistics() {

    memory=`free -m | sed -n '2p' | awk '{print $3}' | tr -d ''`
    redis-cli SET mem ${memory}

}
    

net_traffic_statistics
mem_statistics