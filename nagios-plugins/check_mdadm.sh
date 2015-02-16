#!/bin/bash
# nagios-plugins/check_mdadm.sh
# EugeneKay/scripts
#
# Nagios plugin to check mdadm arrays
#
## Usage
#
# $ check_md [<device>]
#
# Device should be a mdN device name or omitted. Critical will be issued for
# rebuild or failures. Warning will be issued during reshape. Normal or check
# is OK.

## Variables
# Arguments
array="${1}"

# Default to Unknown & no data
code=3
string=""
perfdata=""

# Read through arrays
while read line
do
	# Is this a new array?
	match=$(echo ${line} | egrep -o "^(md[0-9]+)")
	grepcode=$?

	last=$(echo ${line} | egrep -o '^unused devices:')
	lastcode=$?

	if [ "${grepcode}" -eq "0" ] || [ "${lastcode}" -eq "0" ]
	then
		# Were we in the middle of an array?
		if [ -n "${current}" ]
		then
			# Determine array's code
			case "${arraycode}" in
			0)
				arraystring="OK"
				if [ "${code}" -eq 3 ]
				then
					code=0
				fi
				;;
			1)
				arraystring="WARNING"
				if [ "${code}" -ne 2 ]
				then
					code=1
				fi
				;;
			2)
				arraystring="CRITICAL"
				code=2
				;;
			*)
				arraystring="UKNOWN"
				;;
			esac
			string+="${current} is ${arraystring}(${activity}) "
			perfdata+=" ${current}=${percent}"
		fi
		# Reset array info
		activity="idle"
		arraycode=3
		percent="100.0"
		# Do we care about this new array?
		if [ -z "${array}" ] ||  [ "${match}" == "${array}" ]
		then
			current="${match}"
		else
			current=""
			continue
		fi
	fi
	# Are we looking at an array currently?
	if [ -z "${current}" ]
	then
		continue
	fi

	# Look for status
	match=$(echo ${line} | egrep -o "\[[0-9]+/[0-9]+\]")
	grepcode=$?
	# Is this a status line?
	if [ "${grepcode}" -eq "0" ]
	then
		# Pull out segments / devices
		trimmed=$(echo ${match} | tr -d [])
		segments=$(echo "${trimmed}" | cut -d '/' -f 1)
		devices=$(echo "${trimmed}" | cut -d '/' -f 2)
		if [ "${segments}" -gt "${devices}" ]
		then
			arraycode=2
		elif [ "${segments}" -eq "${devices}" ]
		then
			arraycode=0
		fi
	fi

	# Look for activity
	match="$(echo ${line} | egrep -o '(check|recovery|resync|reshape)')"
	grepcode=$?

	# Is this an activity line?
	if [ "${grepcode}" -eq "0" ]
	then
		activity="${match}"
		# Find percentage
		percent="$(echo ${line} | egrep -o " = ([0-9.]+)" | cut -d ' ' -f 3)"
		if [ -z "${percent}" ]
		then
			percent="0.0"
		fi
		# Determine if we need to modify status
		case "${activity}" in
		"check")
			if [ "${arraycode}" -eq 3 ]
			then
				arraycode=0
			fi
			;;
		"recovery")
			arraycode=2
			;;
		"resync")
			if [ "${arraycode}" -ne 2 ]
			then
				arraycode=1
			fi
			;;
		"reshape")
			if [ "${arraycode}" -ne 2 ]
			then
				arraycode=1
			fi
			;;
		*)
			;;
		esac
		continue
	fi
done < /proc/mdstat

echo "${string}|${perfdata}"
exit ${code}
