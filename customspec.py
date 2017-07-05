#!/usr/bin/python2.7
# -*- coding: utf-8 -*-
# For use with newer version of the WAPI that include the next_available function in the create_host method.
# Known NOT to work with 1.0 of the WAPI
import infoblox  # Use this 3rd party library for convenience.
import sys
import os
import requests
import ipaddr
import re

requests.packages.urllib3.disable_warnings()
hostname = os.environ['vmName']
osName=os.environ['eNV_osName']
clusterName=os.environ['UserClusterName']
envName=os.environ['eNV_CliqrDepEnvName']
datacenter=os.environ['UserDataCenterName']
network=os.environ['subnetId']
vlan = re.search('\(([^)]+)', network).group(1)
pg = network.replace("(IDCVSM01)", "")
custSpec = pg + "Template"
z = network.split('-')
envname = z[0]

iba_api = infoblox.Infoblox('10.16.128.160', 'UCSD-Infoblox-Admin', 'OZGANhja<coLl6h+5JGx', '1.6', iba_dns_view='default', iba_network_view='default', iba_verify_ssl=False)

#first find the subnet based on VLAN extended attribute
unet = iba_api.get_network_by_extattrs("VLAN="+vlan)
hostname = os.environ['vmName']  # The VM name should come from CloudCenter. Use the name of the VM as the OS hostname
domain = "corp.irvineco.com"
fqdn = "{}.{}".format(hostname, domain)
network = unet[0]
mask = ipaddr.IPv4Network(network)
umask = mask.netmask
netmask =str(umask)
x = str(mask)
y = x.split(".")
gateway = y[0]+"."+y[1]+"."+y[2]+".1"

##define DNS Servers
if envname == 'PROD':
    dns_server = "10.16.128.128,10.16.128.130,10.16.140.128"
else:
    dns_server = "10.16.171.129,10.16.170.24"



#now let's get an IP address from the subnet and print out the details
try:
    # Create new host record with supplied network and fqdn arguments
    ip = iba_api.create_host_record(network, fqdn)
    print "nicCount=1"
    print "nicIP_0=" + ip
    print "DnsServerList="+dns_server
    print "nicGateway_0="+gateway
    print "nicNetmask_0="+netmask
    print "domainName="+domain
    print "hwClockUTC=true"
    print "timeZone=US/Pacific"
    print "osHostname="+hostname
    print "custSpec=" + custSpec
except Exception as e:
    print e
