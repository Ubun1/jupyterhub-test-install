#!/bin/bash

#update dist
apt update

#dowload install script
wget -P /tmp https://repo.continuum.io/archive/Anaconda3-5.0.1-Linux-x86_64.sh

#install without prompts
bash /tmp/Anaconda3-5.0.1-Linux-x86_64.sh  -b -p /opt/anaconda

