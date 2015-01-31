#!/bin/bash
# nagios-plugins/check_transfer.sh
# EugeneKay/Scripts
#
# Nagios plugin to check bandwidth transfer
#
## Usage
#
# $ check_transfer <Warn> <Crit> <Interface>
#
# Interface should be a valid, present interface. Warn and Crit values in GiB
# of transfer per month.
#
# `vnstat` must be present and the daemon should be collecting regular stats
# for this to be of any use at all.
#

## Constants
# Adjust as needed
VNSTAT=$(which vnstat)

## Variables
# Arguments
warn=$((${1} * 1024 * 1024 * 1024))
crit=$((${2} * 1024 * 1024 * 1024))
interface="${3}"

status=3

transfer=$(vnstat --dumpdb -i ${interface} | grep "m;0;")

in=$(($(echo "${transfer}" | cut -d ';' -f 4) * 1024 * 1024))
out=$(($(echo "${transfer}" | cut -d ';' -f 5) * 1024 * 1024))

echo -n "check_transfer: ${interface} "

if [ "${in}" -gt "${crit}" ] || [ "${out}" -gt "${crit}" ]
then
	echo -n "CRITICAL!"
	status=2
elif [ "${in}" -gt "${warn}" ] || [ "${out}" -gt "${warn}" ]
then
	echo -n "WARNING!"
	status=1
else
	echo -n "OK!"
	status=0
fi

# Performance data
echo " | ${interface}=${in};${out};${warn};${crit}"
exit ${status}
