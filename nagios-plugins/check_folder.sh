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
size="$(echo ${dubytes} | cut -d ' ' -f1)"

# Figure out status
if [ "${dureturn}" -ne "0" ]
then
	code=3
	status="UNKNOWN!"
elif [ "${crit}" -ne 0 ] && [ "${size}" -gt "${crit}" ]
then
	code=2
	status="CRITICAL!"
elif [ "${warn}" -ne 0 ] && [ "${size}" -gt "${warn}" ]
then
	code=1
	status="WARNING!"
else
	code=0
	status="OK!"
fi

# Output status & value
echo "check_folder: ${folder} is ${status} | ${folder}=${size};${warn};${crit}"
exit ${code}
