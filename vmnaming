#!/usr/bin/python

import os
import sys
import random
import string
import socket
import time

# Gather up the information needed from environment variables.
# Need to look at the logs to get the actual env variables names. These are wrong, but givethe right idea

depEnv = os.environ['eNV_CliqrDepEnvName']
osType = os.environ['eNV_osName']
cloud = os.environ['cloud']
dmz= os.environ['eNV_dmz']
func = os.environ['eNV_func']
fqdn = '.<customer domain>'
## split deployment environment and change to lower case.
env = depEnv.split("-")
env2 = env[1].lower()


# Create maps (dictionaries) that associate the CloudCenter info to the custom values that should go into the VM name.
# You will need to look in the callout logs for the keys to use for this.
loc = {
    "GCP": "1",
    "AWS": "2",
    "CLOUD_CLUS-IRVINE": "0"
}

platform = {
    "Windows": "W",
    "Linux": "L"
}

# It might be better to use a tag for this instead of the deployment env.
usage = {
    "dev": "D",
    "prod": "P",
    "test": "T",
    "QA": "Q",
    "SandBox": "S",
    "UAT": "U"
}

#DMZ or NON DMZ
ext = {
         "dmz": "1",
         "non": "0"
         }


# Allow the admin to set a role custom parameter to control that part of the name, but if it
# 's not set then just use "SRV"
# role = os.getenv('role', "SRV")[:3] # Look for a role parameter, return SRV as a default. Cut to first 3 chars only.

genname = 'yes'
##define function to check hostname
def hostname_resolves(hostname):
    try:
        socket.gethostbyname(hostname)
        return True
    except socket.error:
        print "host not resolving!"
        return False



while genname == 'yes':
    # Build out our hostname class structure
    fname = "{usage}{external}{location}-{func}".format(
       location = loc[cloud],
       platform = platform[osType],
       usage = usage[env2],
       external = ext[dmz],
       func = func)

    # Check if there are already other others defined and if so, the number
    if ( not os.path.isfile(fname)):
        print("%s file not found, assuming no hosts exist, starting with 101" % fname)
        # We start with 101 if there is not already one there
        host_num = 101

        # Define our first hostname
        name = "{usage}{external}{location}-{func}-{host_num}".format(
            location = loc[cloud],
            platform = platform[osType],
            usage = usage[env2],
            external = ext[dmz],
            host_num = host_num,
            func = func)

        print ("checking if %s is in dns" % name )

        # Check DNS
        breaker = hostname_resolves(name + fqdn)
        print name + fqdn

        # If it exists, just write it to the file and we will try again
        if breaker:
            host_num += 1
            host_val = str(host_num)
            file = open(fname, 'w')
            file.write(host_val)
            file.close()
            print "write file and try again"
        # If not in DNS, write it out and use it
        if not breaker:
            host_val = str(host_num)
            file = open(fname, 'w')
            file.write(host_val)
            file.close()
            print name
            print "new file should have been created"
            break

    else:
        print("Setting hostname using existing file %s ..." % fname)

        # Open our file, read the string, convet it to our integer
        file = open(fname, "r")
        file_num = file.readline()
        file.close()
        host_num = int(file_num) + 1

        # Define our first hostname
        name = "{usage}{external}{location}-{func}-{host_num}".format(
            location = loc[cloud],
            platform = platform[osType],
            usage = usage[env2],
            external = ext[dmz],
            host_num = host_num,
            func = func)

        print ("checking if %s is in dns" % name )

        # Check DNS
        breaker = hostname_resolves(name + fqdn)

        # If it exists in DNS, increment so we can try again
        if breaker:
            host_num += 1
            print host_num
            #Entry exists in DNS

        # If not in DNS, write it out and use it
        if not breaker:
            host_val = str(host_num)
            file = open(fname, 'w')
            file.write(host_val)
            file.close()
            print name
            break

#print name
# For AD compatibilty, check to ensure the name isn't longer than 15 characters.

if len(name) > 15:
    print("Length of generated name is greater than 15, which is invalid. Exiting")
    sys.exit(1)
else:
    print("vmName={name}".format(name = name))
