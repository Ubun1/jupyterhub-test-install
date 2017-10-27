#!/bin/bash

#install dependencies 
apt update
apt install -y python3 npm nodejs-legacy python3-pip
npm install -g configurable-http-proxy

#install juphub
pip3 install jupyterhub
pip3 install IPython jupyter_client
pip3 install dockerspawner
pip3 install netifaces

#necesary config options
cat << EOF > ./jupyterhub_config.py
from IPython.utils.localinterfaces import public_ips
import netifaces
docker0 = netifaces.ifaddresses('docker0')
docker0_ipv4 = docker0[netifaces.AF_INET][0]

c.JupyterHub.confirm_no_ssl = True
c.JupyterHub.spawner_class = 'dockerspawner.SystemUserSpawner'
c.JupyterHub.hub_ip = docker0_ipv4['addr']
EOF

#pull singleuser server
docker pull jupyterhub/singleuser:0.8

#add test user
adduser --disabled-password --gecos "" stud1

usermod -a -G docker ubuntu
usermod -a -G docker stud1
usermod -a -G sudo stud1

reboot