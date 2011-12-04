#!/bin/bash
##
## IP Wrap
##
#
# IP Wrap is a wrapper for the `ip` command for OpenVPN running in unprivileged
# mode. It allows usage of "ip addr add|del" and "ip link" on tun0-99, and the
# "ip route add|del" command.
#
# Copyright 2011 Eugene E. Kashpureff (eugene@kashpureff.org)
# License: WTFPL, any version or GNU General Public License, version 3+
#

## Check which ip subcommand is being requested
case "$1" in
"addr")
	## Only allow devices tun0-tun99
        if [[ "$4" =~ ^t(un|ap)[0-9]{1,2}$ ]]
        then
		## Only allow add and del commands
                case "$2" in
                "add") /sbin/ip $* ;;
                "del") /sbin/ip $* ;;
                *) /bin/false ;;
                esac
        else
                /bin/false
        fi
        ;;
"link")
	## Only allow devices tun0-tun99
        if [[ "$4" =~ ^t(un|ap)[0-9]{1,2}$ ]]
        then
                /sbin/ip $*
        else
                /bin/false
        fi
        ;;
"route")
        case "$2" in
        "add") /sbin/ip $* ;;
        "del") /sbin/ip $* ;;
        *) /bin/false ;;
        esac
	;;
*) /bin/false ;;
esac

## Exit using the return status of the command run
exit $?
