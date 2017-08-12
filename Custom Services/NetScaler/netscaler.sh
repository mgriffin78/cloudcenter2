#!/bin/bash
. /utils.sh
cmd=$1
print_log $(env)

yum install -y python-pip
pip install pip --upgrade
pip install nsnitro
wget -k  http://10.16.128.104/netscaler/netscaler.py
python netscaler.py ${cmd}
