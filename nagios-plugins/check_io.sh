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

## Variables
# Arguments
device="${1}"
period="${2}"
sector_bytes="512"
warn_bytes="${4}"
crit_byte="${5}"

diskstats="/proc/diskstats"

# De-reference device
if [ -d "${device}" ]
then
	device=$(df --output=source "${device}" | tail -n1)
fi

# Follow any symlinks
device=$(realpath "${device}")

# Handle direct-kernel boot virt
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

# Verify device
if [ ! -b "${device}" ]
then
	echo "UNKNOWN: Invalid Device or Filesystem"
	exit 3
fi

dev=$(echo "${device}" | cut -d '/' -f 3-)

# Beginning count 
begin=$(grep "${dev}" ${diskstats} | tr -s ' ')

# Wait a while...
sleep ${period}

# End count
end=$(grep "${dev}" ${diskstats} | tr -s ' ')

# Calculate sizes
read_sectors=$(($(echo ${end} | cut -d ' ' -f 6) - $(echo ${begin} | cut -d ' ' -f 6)))
writ_sectors=$(($(echo ${end} | cut -d ' ' -f 10) - $(echo ${begin} | cut -d ' ' -f 10)))

# Calculate bytes moved per second
read_bytes=$(echo "${read_sectors} * ${sector_bytes} / ${period}" | ${BC})
writ_bytes=$(echo "${writ_sectors} * ${sector_bytes} / ${period}" | ${BC})

# Calculate human rate
read_rate=$(echo ${read_bytes} | ${AWK} 'function human(x) {s="bkMGTEPYZ";while (x>=1000 && length(s)>1){x/=1024;s=substr(s,2)}return int(x*100)/100 substr(s,1,1)}{gsub(/^[0-9]+/, human($1)); print}')
writ_rate=$(echo ${writ_bytes} | ${AWK} 'function human(x) {s="bkMGTEPYZ";while (x>=1000 && length(s)>1){x/=1024;s=substr(s,2)}return int(x*100)/100 substr(s,1,1)}{gsub(/^[0-9]+/, human($1)); print}')

# Determine status
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

# Output status & performance data
echo "check_io: ${dev} is ${status}(Read ${read_rate} Writ ${writ_rate}) | ${dev}_io=${read_bytes};${writ_bytes};${warn_bytes};${crit_bytes}"

# Exit appropriately
exit ${code}
