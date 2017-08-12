
from nsnitro import *
import os
import sys


# Gather up all the custom parameters
VS_ADDRESS = os.getenv('vipAddress')
VS_PORT = os.getenv('vsPort')
RS_PORT = os.getenv('rsPort')
POOL_LB_METHOD = os.getenv('lbMethod')
deviceIp = os.getenv('deviceIp')
deviceUser = os.getenv('deviceUser')
devicePass = os.getenv('devicePass')
parentJobId = os.getenv('parentJobId')
cliqr_dependencies = os.getenv('CliqrDependencies')
cmd = sys.argv[1]

#Set object names unique to job ID
VS_NAME = "cliqr_{parentJobId}_vip".format(parentJobId = parentJobId)
POOL_NAME = "cliqr_{parentJobId}_pool".format(parentJobId = parentJobId)

#Create list of dependent service tiers
dependencies = cliqr_dependencies.split(",")


#print dependencies

#Set the new server list from the CliQr environment
serverList = []

for dependency in dependencies:
    serverIp = os.getenv("CliqrTier_"+dependency+"_PUBLIC_IP")
    serverHostName = os.getenv("CliqrTier_"+dependency+"_HOSTNAME")
    serverList.append({'ip': serverIp, 'hostname': serverHostName})

#print serverList

#for server in serverList:
#    print server


nitro = NSNitro(deviceIp, deviceUser, devicePass)
r = nitro.login()

#print r
#hostname  = serverNodes[0].replace('"','')
#ipaddress = serverIps[0].replace('"','')

def start():

    for server in serverList:
        addserver = NSServer()
        addserver.set_name(server['hostname'])
        addserver.set_ipaddress(server['ip'])
        NSServer.add(nitro, addserver)

        addservice = NSService()
        addservice.set_name(server['hostname'])
        addservice.set_servername(server['hostname'])
        addservice.set_servicetype("HTTP")
        addservice.set_port(RS_PORT)
        NSService.add(nitro, addservice)

    lbvserver = NSLBVServer()
    lbvserver.set_name(VS_NAME)
    lbvserver.set_ipv46(VS_ADDRESS)
    lbvserver.set_port(VS_PORT)
    lbvserver.set_clttimeout(180)
    lbvserver.set_persistencetype("NONE")
    lbvserver.set_servicetype("HTTP")
    NSLBVServer.add(nitro, lbvserver)

    for server in serverList:
        lbbinding = NSLBVServerServiceBinding()
        lbbinding.set_name(VS_NAME)
        lbbinding.set_servicename(server['hostname'])
        lbbinding.set_weight(40)
        NSLBVServerServiceBinding.add(nitro, lbbinding)

def destroy():
    for server in serverList:
        lbbinding = NSLBVServerServiceBinding()
        lbbinding.set_name(VS_NAME)
        lbbinding.set_servicename(server['hostname'])
        NSLBVServerServiceBinding.delete(nitro, lbbinding)

        delservice = NSService()
        delservice.set_name(server['hostname'])
        NSService.delete(nitro, delservice)

        delserver = NSServer()
        delserver.set_name(server['hostname'])
        NSServer.delete(nitro, delserver)

    lbvserver = NSLBVServer()
    lbvserver.set_name(VS_NAME)
    NSLBVServer.delete(nitro, lbvserver)


if cmd == "start":
    start()
elif cmd == "stop":
    destroy()

