#!/bin/bash

. /utils.sh
cmd=$1

echo "Started successfully..."
echo "Executing command $(cmd)"

yum install -y python-pip wget
pip install pip --upgrade
pip install pan-python
pip install xmltodict

wget -k http://10.16.128.104/paloalto/panconfig.py
wget -k http://10.16.128.104/paloalto/address.xml
wget -k http://10.16.128.104/paloalto/policy.xml


print_log $(env)

pan_host=$(env | grep pan_host | awk -F'=' '{print $2}')
pan_user=$(env | grep pan_user | awk -F'=' '{print $2}')
pan_pass=$(env | grep pan_pass | awk -F'=' '{print $2}')

echo $pan_host
echo $pan_user
echo $pan_pass

apikey=$(panxapi.py -l $pan_user:$pan_pass -h $pan_host -k | grep -o '".*"' | tr -d '"')
apikey=$(panxapi.py -l $pan_user:$pan_pass -h $pan_host -k | grep -o '".*"' | tr -d '"')
echo $apikey
echo 'hostname='$pan_host > ~/.panrc
echo 'api_key='$apikey >> ~/.panrc

cat ~/.panrc


wget -k http://10.16.128.104/paloalto/.panrc

python panconfig.py $cmd

