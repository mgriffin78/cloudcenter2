#!/usr/bin/env python
import infoblox
import requests
import os
requests.packages.urllib3.disable_warnings()
domain = os.environ['eNV_domain']

fqdn = os.environ['vmName'].lower()+"."+domain
iba_api = infoblox.Infoblox('10.16.128.160', '<infoblox-user>', '<infoblox-passwd>', '1.6', iba_dns_view='default', iba_network_view='default', iba_verify_ssl=False)

try:
    # Create new host record with supplied network and fqdn arguments
    ip = iba_api.delete_host_record(fqdn)
except Exception as e:
    print e
