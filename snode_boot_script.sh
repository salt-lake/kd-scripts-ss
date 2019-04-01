#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin;
export PATH

function check_git() {

  if ! [ -x "$(command -v git)" ]; then
    apt-get update
    apt-get install -y git
  fi
}


function check_node(){
   if ! [ -x "$(command -v node)" ]; then
       curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
       apt-get install -y nodejs
       apt-get install -y build-essential
       npm install pm2 -g
   fi
}


function check_redis(){
  if ! [ -x "$(command -v redis-server)" ]; then
    apt-get update
    apt-get install -y redis-server
  fi
}


function check_proxy(){
  if [ ! -d "/home/kd-proxy" ]; then
    cd /home
    git clone https://github.com/youfangkeji/kd-proxy-ss
  else
    cd /home/kd-proxy
    git pull
  fi
}


function deploy_proxy(){
  cd /home/kd-proxy
  git pull
  npm install
}


function create_cron(){

  if [ ! -d "/home/kd-scripts-ss" ]; then
    cd /home
    git clone https://github.com/youfangkeji/kd-scripts-ss
  else
    cd /home/kd-scripts-ss
    git pull
  fi
}



function add_cron(){

  (
    echo "* * * * * cd /home/kd-scripts-ss/cron && /bin/bash cron-job-min.sh >> /home/min.log"
    echo "* * * * * cd /home/kd-scripts-ss/cron && /bin/bash system_info_statistics.sh"
  ) | crontab -u root -
}


function init() {
  check_git
  check_node
  check_redis
  check_proxy
  deploy_proxy
  create_cron
  add_cron
}


init