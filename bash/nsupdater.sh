#!/bin/bash
##
## NS Updater
##
#
# NS Updater is a script which checks your current public IP address against the
# existing record, and updates it if necessary using a TSIG key. Will eventually
# support IPv6 updates and additional record types(such as SSHFP) as well.
#
# Copyright 2011 Eugene E. Kashpureff (eugene@kashpureff.org)
# License: WTFPL, any version or GNU General Public License, version 3+
#

##
## Constants
##

# Domain to perform the update in
DOMAIN="dynamic.example.com"

# Record to update(usually your hostname)
RECORD="host"

# Dynamic update keyname
KEYNAME="dynamic-key"

# HMAC-MD5 secret, generated using dnssec-keygen
KEYSECRET="XXXXXXXXXXXXXXXXXXXXXX==" 

# Server to update against
SERVER="ns1.example.com"
# NOTE: This could be guessed from the SOA record by nsupdate, but specifying it
# explicitly is arguably more robust(eg, incorrect SOA record or failed query)

# Time-To-Live for the record
TTL="300"

##
## Check & Update
##

# Get the current publically-visible IP
# TODO: check IPv6 as well
pubip=$(wget -qO- "http://ipv4.eugenekay.com/myip.php?o=plain")

# Get the current IP on file with DNS
dnsip=$(dig +short @${SERVER} ${RECORD}.${DOMAIN} A)

# Check the Public IP against the DNS IP
if [ "${pubip}" != "${dnsip}" ]
then
        # Build the update query
	# TODO: add prerequisites, update AAAA as well
        update="server ${SERVER}\n"
        update="${update}zone ${DOMAIN}\n"
        update="${update}update delete ${RECORD}.${DOMAIN}\n"
        update="${update}update add ${RECORD}.${DOMAIN} ${TTL} IN A ${pubip}\n"
        update="${update}send\n"

        # Run the update
        echo -e ${update} | nsupdate -y ${KEYNAME}:${KEYSECRET}

        # Check that the update went through
        newip=$(dig a ${RECORD}.${DOMAIN} +short)
        if [ "${pubip}" != "${newip}" ]
        then
                echo "Failed to update ${RECORD}.${DOMAIN} to ${pubip} using key ${KEYNAME}"
        else
                echo "Successfully updated ${RECORD}.${DOMAIN} to ${pubip}."
        fi
fi

## Cleanup

# Unset script constants
unset DOMAIN RECORD KEYNAME KEYSECRET SERVER TTL

# Unset script variables
unset pubip dnsip update newip

# TODO: give a meaningful exit status
