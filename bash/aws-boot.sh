#!/bin/bash
#
# AWS Boot
#
# Load data about an AWS instance and set up the system at boot time.
#
# Copyright 2011 Eugene E. Kashpureff (eugene@kashpureff.org)
# License: WTFPL, any version or GNU General Public License, version 3+
#

##
## Options
##
# These should all be set, unless documented otherwise

## DNS
# Domain to perform update in. Can be overriden by the user-data 'domain' field.
DOMAIN=""

# Dynamic update keyname
KEY=""

# HMAC-MD5 secret, generated using dnssec-keygen
SECRET="" 

# Server to update against
DNS_SERVER=""

# Time-To-Live for records
TTL="300"

## Hostname
# List of services which must be restarted to. Space-separated.
DAEMONS="rsyslog "


##
## Constants
##
# You should not need to change these, but you may.

## Script
# Working directory
WORKDIR="/tmp/aws-boot"

# Concurrency lock dir
LOCKDIR="${WORKDIR}/.lock"

# Location of AWS userdata file
USERDATA="${WORKDIR}/USERDATA"


##
## Script Lock
##

# Create working directory if not exist
mkdir -p ${WORKDIR}

# Attempt to acquire lock
if mkdir "${LOCKDIR}"
then
	echo $$ > "${LOCKDIR}/pid"
else
	echo "Error: Unable to acquire script lock"
	exit
fi

# Remove lock on exit, even if abnormal
trap "rm -rf ${LOCKDIR}; exit" INT TERM EXIT


##
## Variables
##

# Userdata
userdata="$(curl http://169.254.169.254/latest/user-data 2>/dev/null | tee ${USERDATA})"

## Instance ID
instance_id="$(curl http://169.254.169.254/latest/meta-data/instance-id 2>/dev/null)"

# Public IP
public_ipv4="$(curl http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null)"

# Timestamp
timestamp="$(date +'%s %Y-%m-%d %0H:%M:%S %:z(%Z)')"


##
## Runtime
##

## Domain
# From the user-data file
domain=$(grep "^domain" ${USERDATA} | head -n1 | cut -d "|" -f 2)

# Fall back to option-specified
if [ -z "${domain}" ]
then
	domain=${DOMAIN}
fi


## Hostname
# Hostname from the user-data file
hostname=$(grep "^hostname" ${USERDATA} | head -n1 | cut -d "|" -f 2)

# Fall back to instance ID
if [ -z "${hostname}" ]
then
	hostname="${instance_id}"
fi

# Set system hostname
/bin/hostname "${hostname}.${domain}"

# Restart daemons which depend upon hostname
for daemon in "${DAEMONS}"
do
	/sbin/service ${daemon} restart
done


## DNS update
# Perform a Dynamic DNS update

# Build the update query
update="server ${DNS_SERVER}\n"
update+="zone ${domain}\n"
update+="update delete ${hostname}.${domain}\n"
update+="update add ${hostname}.${domain} ${TTL} IN A ${public_ipv4}\n"
update+="update add ${hostname}.${domain} ${TTL} IN TXT \"Updated ${timestamp}\"\n"
if [ -f /etc/ssh/ssh_host_rsa_key.pub ]
then
	rsakey=$(cat /etc/ssh/ssh_host_rsa_key.pub | cut -d ' ' -f 2 | openssl base64 -d -A | openssl sha1 | cut -d ' ' -f 2)
	update+="update add ${hostname}.${domain} ${TTL} IN SSHFP 1 1 ${rsakey}\n"
fi
if [ -f /etc/ssh/ssh_host_dsa_key.pub ]
then
	dsakey=$(cat /etc/ssh/ssh_host_dsa_key.pub | cut -d ' ' -f 2 | openssl base64 -d -A | openssl sha1 | cut -d ' ' -f 2)
	update+="update add ${hostname}.${domain} ${TTL} IN SSHFP 2 1 ${dsakey}\n"
fi
if [ "${hostname}" != "${instance_id}" ]
then
	update+="update delete ${instance_id}.${domain}\n"
	update+="update add ${instance_id}.${domain} ${TTL} IN CNAME ${instance_id}.${domain}\n"
fi
update+="send\n"

# Run the update
echo -e ${update} | nsupdate -y ${KEY}:${SECRET}


##
## Cleanup
##

# Exit cleanly
exit 0
