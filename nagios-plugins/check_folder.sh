#!/bin/bash
# nagios-plugins/check_folder.sh
# EugeneKay/scripts
#
# Nagios plugin to check Folder size
#
## Usage
#
# $ check_folder <folder> [<warn> <crit>]
#
# Check a given folder's size-on-disk using `du`. Warning and critical values
# are optional, and specify the size(in bytes) above which the respective alert
# should be triggered.
#

## Constants
# Adjust as needed
DU=$(which du)
AWK=$(which awk)

## Variables
# Arguments
folder="${1}"
warn="${2}"
crit="${3}"

# Default to zero
if [ -z "${warn}" ]
then
	warn="0"
	crit="0"
fi

# Check if folder exists
if [ ! -d "${folder}" ]
then
	echo "UNKNOWN: Invalid folder"
	exit 3
fi

# Get number of bytes used
dubytes=$(${DU} -sb ${folder})
dureturn="$?"

# Extract byte count
bytes="$(echo ${dubytes} | cut -d ' ' -f1)"

# Get a human size
size=$(echo ${bytes} | ${AWK} 'function human(x) {s="bkMGTEPYZ";while (x>=1000 && length(s)>1){x/=1024; s=substr(s,2)}return int(x*100)/100 substr(s,1,1)}{gsub(/^[0-9]+/, human($1)); print}')

# Figure out status
if [ "${dureturn}" -ne "0" ]
then
	code=3
	status="UNKNOWN!"
elif [ "${crit}" -ne 0 ] && [ "${bytes}" -gt "${crit}" ]
then
	code=2
	status="CRITICAL!"
elif [ "${warn}" -ne 0 ] && [ "${bytes}" -gt "${warn}" ]
then
	code=1
	status="WARNING!"
else
	code=0
	status="OK!"
fi

# Output status & value
echo "check_folder: ${folder} is ${status}(${size}) | ${folder}=${bytes};${warn};${crit}"
exit ${code}
