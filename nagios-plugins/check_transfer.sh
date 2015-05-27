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
AWK=$(which awk)
VNSTAT=$(which vnstat)

## Variables
# Arguments
warn=$((${1} * 1024 * 1024 * 1024))
crit=$((${2} * 1024 * 1024 * 1024))
interface="${3}"

string="UNKNOWN"
code=3

transfer=$(vnstat --dumpdb -i ${interface} | grep "m;0;")

in=$(($(echo "${transfer}" | cut -d ';' -f 4) * 1024 * 1024))
out=$(($(echo "${transfer}" | cut -d ';' -f 5) * 1024 * 1024))
coming=$(($(vnstat --dumpdb -i ${interface} | grep ^d | cut -d ';' -f 4 | paste -sd+ | bc) * 1024 * 1024))
going=$(($(vnstat --dumpdb -i ${interface} | grep ^d | cut -d ';' -f 5 | paste -sd+ | bc) * 1024 * 1024))

rx=$(echo ${in} | ${AWK} 'function human(x) {s="bkMGTEPYZ";while (x>=1000 && length(s)>1){x/=1024; s=substr(s,2)}return int(x*100)/100 substr(s,1,1)}{gsub(/^[0-9]+/, human($1)); print}')
tx=$(echo ${out} | ${AWK} 'function human(x) {s="bkMGTEPYZ";while (x>=1000 && length(s)>1){x/=1024; s=substr(s,2)}return int(x*100)/100 substr(s,1,1)}{gsub(/^[0-9]+/, human($1)); print}')

if [ "${in}" -gt "${crit}" ] || [ "${out}" -gt "${crit}" ]
then
	string="CRITICAL!"
	code=2
elif [ "${in}" -gt "${warn}" ] || [ "${out}" -gt "${warn}" ]
then
	string="WARNING!"
	code=1
else
	string="OK!"
	code=0
fi

# Performance data
echo "check_transfer: ${interface} is ${string}(RX ${rx} TX ${tx}) | ${interface}=${in};${out};${warn};${crit};${coming};${going}"
exit ${code}
