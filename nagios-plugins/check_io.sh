#!/bin/bash
# nagios-plugins/check_io.sh
# EugeneKay/scripts
#
# Nagios plugin to check device I/O
#
## Usage
#
# $ check_io <device> <period> [<warn> <crit>]
#
# Device: device or filesystem on which to report statistics
# Period: length of time over which to collect statistics, in seconds
# Warn / Crit: Speed in byte/s at which to trigger alarm
#

## Constants
# Adjust as needed
AWK=$(which awk)
BC=$(which bc)
DISKSTATS="/proc/diskstats"

## Variables
# Arguments
device="${1}"
period="${2}"
sector_bytes="512"
warn_bytes="${4}"
crit_byte="${5}"

## Device detection
# Is it a PV UUID?
if [ -n "$(echo ${device} | egrep '\w{6}-(\w{4}-){5}\w{6}')" ]
then
	device=$(sudo pvs -o pv_uuid,pv_name | grep "${device}" | cut -d ' ' -f 4)
fi

# De-reference device
if [ -d "${device}" ]
then
	# Get actual filesystem
	device=$(df --output=source "${device}" | tail -n1)
fi

# Handle root device
if [ "${device}" == "/dev/root" ]
then
	if [ -b "/dev/sda" ]
	then
		device="/dev/sda"
	elif [ -b "/dev/xvda" ]
	then
		device="/dev/xvda"
	fi
fi

# Follow symlinks
if [ -L "${device}" ]
then
	device="$(readlink -e ${device})"
fi

# Verify device
if [ ! -b "${device}" ]
then
	echo "UNKNOWN: Invalid Device or Filesystem"
	exit 3
fi

dev=$(echo "${device}" | cut -d '/' -f 3-)

## Data collection
# Beginning count 
begin=$(grep "${dev}" ${DISKSTATS} | tr -s ' ')

# Wait a while...
sleep ${period}

# End count
end=$(grep "${dev}" ${DISKSTATS} | tr -s ' ')

# Calculate sizes
read_sectors=$(($(echo ${end} | cut -d ' ' -f 6) - $(echo ${begin} | cut -d ' ' -f 6)))
writ_sectors=$(($(echo ${end} | cut -d ' ' -f 10) - $(echo ${begin} | cut -d ' ' -f 10)))

# Calculate bytes moved per second
read_bytes=$(echo "${read_sectors} * ${sector_bytes} / ${period}" | ${BC})
writ_bytes=$(echo "${writ_sectors} * ${sector_bytes} / ${period}" | ${BC})

# Calculate human rate
read_rate=$(echo ${read_bytes} | ${AWK} 'function human(x) {s="bkMGTEPYZ";while (x>=1000 && length(s)>1){x/=1024;s=substr(s,2)}return int(x*100)/100 substr(s,1,1)}{gsub(/^[0-9]+/, human($1)); print}')
writ_rate=$(echo ${writ_bytes} | ${AWK} 'function human(x) {s="bkMGTEPYZ";while (x>=1000 && length(s)>1){x/=1024;s=substr(s,2)}return int(x*100)/100 substr(s,1,1)}{gsub(/^[0-9]+/, human($1)); print}')

## State determination
if [ ${read_bytes} -lt 0 ] || [ ${writ_bytes} -lt 0 ]
then
	code=3
	status="UNKNOWN!"
elif [ -z "${warn_bytes}" ] || [ -z "${crit_bytes}" ]
then
	warn_bytes="0"
	crit_bytes="0"
	code=0
	status="OK!"
else
	if [ ${warn_bytes} -eq 0 ] && [ ${crit_bytes} -eq 0 ]
	then
		code=0
		status="OK!"
	elif [ ${read_bytes} -gt ${crit_bytes} ] || [ ${writ_bytes} -gt ${crit_bytes} ]
	then
		code=2
		status="CRITICAL!"
	elif [ ${read_bytes} -gt ${warn_bytes} ] || [ ${read_bytes} -gt ${warn_bytes} ]
	then
		code=1
		status="WARNING!"
	else
		code=0
		status="OK!"
	fi
fi


## Output
# Info & perfdata
echo "check_io: ${dev} is ${status}(Read ${read_rate}/s Writ ${writ_rate}/s) | ${dev}_io=${read_bytes};${writ_bytes};${warn_bytes};${crit_bytes}"

# Exit appropriately
exit ${code}
