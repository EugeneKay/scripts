#!/bin/bash
# 
# ssh-sshfp
#
# Generate the text needed for SSHFP records 
#
# Copyright 2012 Eugene E. Kashpureff (eugene@kashpureff.org)
# License: WTFPL, any version or GNU General Public License, version 3+
#

echo "`hostname`	SSHFP	1 1 `cat /etc/ssh/ssh_host_rsa_key.pub | cut -d ' ' -f 2 | openssl base64 -d -A | openssl sha1 | cut -d ' ' -f 2`"
echo "`hostname`	SSHFP	2 1 `cat /etc/ssh/ssh_host_dsa_key.pub | cut -d ' ' -f 2 | openssl base64 -d -A | openssl sha1 | cut -d ' ' -f 2`"
