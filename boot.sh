#!/bin/bash
# init the ss hosts when created

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin;
export PATH

# enable ipv4 precedence
if ! grep '^precedence ::ffff:0:0/96  100' /etc/gai.conf; then
    echo 'precedence ::ffff:0:0/96  100' >> /etc/gai.conf
fi

# increase the num of file descriptor
if ! grep '^ulimit -n 65535' ~/.profile; then
    echo 'ulimit -n 65535' >> ~/.profile
    source ~/.profile
fi

# config ssh can only use public key to log in
function config_ssh(){
    
    # disable passowrd
    if grep '^PasswordAuthentication' /etc/ssh/sshd_config; then
        sed -re 's/^(PasswordAuthentication)([[:space:]]+)yes/\1\2no/' -i.`date -I` /etc/ssh/sshd_config
    else
        echo PasswordAuthentication no >> /etc/ssh/sshd_config
    fi
    
    # input the public keys
    if [ ! -d "~/.ssh" ]; then
        mkdir ~/.ssh
    fi    
    cd ~/.ssh
    echo ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCztBCQ0uJeccSApdta3q5hO0NICh0+DSYkIcRGV6qxB/2o/AAcn0vkWtJrsZXavC3J+Vj6DYuynqm1FOfcuqbk3gnjQrQkHmkH3gYTMmZFz1vi76sOtlW1+lWjk6is+DtPRuoPzjku1WYW6nGbwcK0at6kUsQvcKCzqv0+42xYscIsKzWmMSoDSfaCJrdVlQXnLXk4128mmjP80TnGror9lCMrAu9PTTznFixAw3I2ElrCsQW5a/y9qw2AyMvJtYh+ELjXIb3RNe1m81L9KhfFmpr09jNcvdL5Dvw1fwiPywE6A1svJaIVbSUyefmRlKDwfeAVVb8hiX7EjgPfRSQ/ frank@FrankdeMacBook-Pro.local >> authorized_keys
    echo ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDWiGprMMV8rQ4BEtwi23JGIDY8DyoW+ZkPPB0VZDCxLJWBWEky76pvB1jJN/j1+ZT6NFUj456aN24IhGFXfCt20HoqefEeaz8RyNwLYFh+VMj890Iek0+XztiIgq6Ah1p3+ll65WGa319UDB1P5i8vfq1ehgmY7GB2ysh4RL1qPzgvDdTZf0yYjsLrEbGoVaj0NA/HJwmw/lGEQe0TEeUofUh+KkLkxXk/xA6jmpCxCEq6zfDCENlZnsMRWiY+Qa1INIlJ72/M7JPsv8krcPtxcEDgOzVQBIxxwgzJLAsJ4S8yo/9fG6rJ4HWTn0F0fBGfJGL5KQM5I2NU5nMLa5T5 frank@FrankdeMacBook-Pro.local >> authorized_keys
    echo ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDbuBUBN+ruO4bSNMby4F3l8kT33rCr2KnjOT7k+UhjPBJqNSLIJL5EGNEWBeFAnVOZZ3ED0T/SeCerqdUr+CdM8GKQ3o+v6rC7ZS3KiSZSeGy2s8W04xiny/jnYoolzRo5uXQmj3gWOPPcoOVDhKR3ypOsFTVdTs9/EW0dw01Z2lHvf2XkFq7oa9Q4Ss5a5CoT9Qwtgh/CT3HoziFVrZ6ZBhDsTdnEQl3o8Yg2AO/LzPfNBRG603lqHN6MnARaYJIPLogknUDWvUId/A/dB/kWdgHNxHrkf77XgbLxg/J1QFgS5lHqZotGYhATV4fyX22lVEaYteO0qnONTsDTsuMb zerobxx@163.com >> authorized_keys
    chmod 600 authorized_keys
    service sshd restart
    
}

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
    git clone https://github.com/youfangkeji/kd-scripts-ss.git
  else
    cd /home/kd-scripts-ss
    git pull
  fi
}

pre_install() {
    config_ssh
    check_git
    check_scripts
}

pre_install    
bash /home/kd-scripts-ss/deploy.sh
bash /home/kd-scripts-ss/optimize.sh
