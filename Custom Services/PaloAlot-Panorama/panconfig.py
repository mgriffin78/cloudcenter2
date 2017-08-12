#!/usr/bin/env python

import os
import sys
from xml.etree import ElementTree
import pan.xapi
import xmltodict


cmd = sys.argv[1]


pan_os_xapi = pan.xapi.PanXapi()

cliqr_dependencies = os.getenv("CliqrDependencies")
dependencies = cliqr_dependencies.split(",")

rule_to_copy = os.getenv("src_rule")
devicegroup = os.getenv("vsys")

src_tier = os.getenv("src_tier")
dst_tier = os.getenv("dst_tier")

policy_name = os.getenv("parentJobName")

ADDR_XPATH="/config/devices/entry[@name='localhost.localdomain']/device-group/entry[@name='%s']/address" %(devicegroup)

RULES_XPATH = "/config/devices/entry[@name='localhost.localdomain']/device-group/entry[@name='%s']/pre-rulebase/security/rules" %(devicegroup)

SRC_POLICY_XPATH="/config/devices/entry[@name='localhost.localdomain']/device-group/entry[@name='%s']/pre-rulebase/security/rules/entry[@name='%s']" %(devicegroup, rule_to_copy)

DST_POLICY_XPATH="/config/devices/entry[@name='localhost.localdomain']/device-group/entry[@name='%s']/pre-rulebase/security/rules/entry[@name='%s']" %(devicegroup, policy_name)

Tier_dict = {"src_list": [], "dst_list": []}

src_server_ips = []
src_server_hostnames = []
dst_server_ips = []
dst_server_hostnames = []

for dependency in dependencies:

        serverIps = os.getenv("CliqrTier_"+dependency+"_PUBLIC_IP").split(",")
        serverHostNames = os.getenv("CliqrTier_"+dependency+"_HOSTNAME").split(",")
        print serverIps
        print serverHostNames
        if dependency in src_tier:
            src_server_ips.extend(serverIps)
            src_server_hostnames.extend(serverHostNames)
        else:
            dst_server_ips.extend(serverIps)
            dst_server_hostnames.extend(serverHostNames)

src_list = zip(src_server_ips, src_server_hostnames)
dst_list = zip(dst_server_ips, dst_server_hostnames)

for i in src_list:
    Tier_dict["src_list"].append({i[1] : i[0]})

for i in dst_list:
    Tier_dict["dst_list"].append({i[1] : i[0]})


def generate_address_elem(hostname, ip):
    with open("address.xml", "r") as f:
        tree = ElementTree.parse(f)
    root = tree.getroot()
    root.attrib['name'] = hostname

    netmask = tree.find('./ip-netmask')
    netmask.text = ip+'/32'

    address_elem = ElementTree.tostring(root, encoding="utf-8", method="xml")
    return address_elem


def pan_add_address(address):
    pan_os_xapi.set(ADDR_XPATH, element=address)


for i in Tier_dict["src_list"]:
    print "+"*80
    hostname, ip = i.items()[0]
    address_elem = generate_address_elem(hostname, ip)
    #print address_elem
    pan_add_address(address_elem)
    #print "+"*80

for i in Tier_dict["dst_list"]:
    #print "+"*80
    hostname, ip = i.items()[0]
    address_elem = generate_address_elem(hostname, ip)
    #print address_elem
    pan_add_address(address_elem)
    #print "+"*80

def generate_endpoint_elem(endpoint):
    members = ""
    tpl = "<member>%hostname%</member>"
    endpoint_list = Tier_dict["src_list"] if endpoint == "source" else Tier_dict["dst_list"]
    for i in endpoint_list:
        hostname, ip = i.items()[0]
        member = tpl
        member = tpl.replace("%hostname%", hostname)
        members += member + "\n"

    #print members
    endpoint = "<%s>\n%s</%s>" %(endpoint, members, endpoint)
    return endpoint


def pan_clone_policy():
    pan_os_xapi.clone(xpath=RULES_XPATH, xpath_from=SRC_POLICY_XPATH, newname=policy_name)

def pan_edit_policy(endpoint):
    endpoint_elem = generate_endpoint_elem(endpoint)
    pan_os_xapi.edit(xpath=DST_POLICY_XPATH+"/%s" %(endpoint), element=endpoint_elem)

pan_clone_policy()

pan_edit_policy("source")
pan_edit_policy("destination")

print generate_endpoint_elem("source")
print generate_endpoint_elem("destination")

#pan_os_xapi.clone(xpath="/config/devices/entry[@name='localhost.localdomain']/device-group/entry[@name='DEV']/pre-rulebase/security/rules", xpath_from="/config/devices/entry[@name='localhost.localdomain']/device-group/entry[@name='DEV']/pre-rulebase/security/rules/entry[@name='CC DMZ-WEB Template SQL Rule']", newname="CC DMZ-WEB Tpl SQL Rule")


