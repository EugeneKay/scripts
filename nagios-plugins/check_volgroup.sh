#!/bin/bash
# nagios/check_volgroup.sh
# EugeneKay/Scripts
#
# Nagios plugin to check VolGroup space usage
#
## Usage
#
# $ check_volgroup <Warn> <Crit> [<VolGroup>...]
#
# VolGroup should be a valid VolGroup name or omitted. Warn and Crit values
# should be the integer percentage above which their respective statuses will
# trigger.
#
# User must be able to execute `vgs` via sudo without tty or password. Minimal
# checks are made against arguments. Invoke via a script only.
#

## Constants
# Adjust as needed
VGS=$(which vgs)
SUDO=$(which sudo)

## Variables
# Arguments
warn="${1}"
crit="${2}"
shift 2
volgroup="${@}"

# Default to Unknown & no data
code=3
string=""
perfdata=""

# Inquire about VolGroup
vgsdata=$(${SUDO} ${VGS} ${volgroup} --units B -o vg_name,vg_size,vg_free --noheadings --nosuffix --separator ' ' 2>/dev/null)

# Parse VolGroup info
while read name sizebytes freebytes
do
	# Sanity check
	if [ -z "${name}" ]
	then
		continue
	fi

	string+="${name} is "

	# Determine levels
	usedbytes=$(( ${sizebytes} - ${freebytes} ))
	warnbytes=$(( ${sizebytes} * ${warn} / 100 ))
	critbytes=$(( ${sizebytes} * ${crit} / 100 ))
	percent=$(( ${usedbytes} * 100 / ${sizebytes} ))

	# Critical level
	if [ "${usedbytes}" -gt "${critbytes}" ]
	then
		code=2
		string+="CRITICAL!"
	# Warning level, if not already Critical from other VGs
	elif [ "${usedbytes}" -gt "${warnbytes}" ] && [ "${code}" -ne "2" ]
	then
		code=1
		string+="WARNING!"
	# Set to OK only if currently Unknown
	elif [ "${code}" -eq "3" ]
	then
		code=0
		string+="OK!"
	fi

	# Append performance data
	string+="(${percent}%) "
	perfdata+=" ${name}=${usedbytes};${warnbytes};${critbytes};0;${sizebytes}"

done <<< "${vgsdata}" 2>/dev/null

# Output status & performance data
echo "check_volgroup: ${string}|${perfdata}"

# Exit appropriately
exit ${code}
