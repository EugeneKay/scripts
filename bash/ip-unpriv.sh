#!/bin/bash
#
# IP Unpriv
#
# This is a helper script for OpenVPN when running in unprivileged mode. It is 
# used to call IP Wrap via sudo, where additional checks can be performed prior
# to invoking the `ip` command.
#
# Copyright 2011 Eugene E. Kashpureff (eugene@kashpureff.org)
# License: WTFPL, any version or GNU General Public License, version 3+
#

## Launch IP Wrap via sudo
sudo /usr/local/sbin/ip-wrap $*

## Exit with the given return status
exit $?
