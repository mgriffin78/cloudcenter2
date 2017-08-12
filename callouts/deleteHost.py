#!/usr/bin/env python
import infoblox
import requests
import os
requests.packages.urllib3.disable_warnings()

fqdn = os.environ['vmName'].lower()+".corp.irvineco.com"
iba_api = infoblox.Infoblox('10.16.128.160', 'UCSD-Infoblox-Admin', 'OZGANhja<coLl6h+5JGx', '1.6', iba_dns_view='default', iba_network_view='default', iba_verify_ssl=False)

try:
    # Create new host record with supplied network and fqdn arguments
    ip = iba_api.delete_host_record(fqdn)
except Exception as e:
    print e
