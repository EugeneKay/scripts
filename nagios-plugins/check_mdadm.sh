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
	if [ "${grepcode}" -eq "0" ]
	then
		# Were we in the middle of an array?
		if [ -n "${current}" ]
		then
			# Was anything found about it?
			if [ -z "${condition}" ]
			then
				# Must be good!
				if [ "${code}" -eq "3" ]
				then
					code=0
				fi
				string+="${current} is OK "
				perfdata+=" ${current}=100.0"
			fi
		fi
		condition=""
		percent=""
		# Do we care about this new array?
		if [ -z "${array}" ] ||  [ "${match}" == "${array}" ]
		then
			current="${match}"
		else
			current=""
			continue
		fi
	fi
	# Have we found any arrays yet?
	if [ -z "${current}" ]
	then
		continue
	fi

	# Look for status
	match="$(echo ${line} | egrep -o '(check|rsync|reshape)')"
	grepcode=$?

	# Is this a status line?
	if [ "${grepcode}" -eq "0" ]
	then
		condition="${match}"
	else
		# Are we at the end?
		match=$(echo ${line} | egrep -o '^unused devices:')
		if [ "$?" -eq "0" ]
		then
			# Any info about this array yet?
			if [ -z "${condition}" ]
			then
				# Last array was good!
				if [ "${code}" -eq "3" ]
				then
					code=0
				fi
				string+="${current} is OK "
				perfdata+=" ${current}=100.0"
			fi
		fi
		continue
	fi
	# Find percentage
	percent="$(echo ${line} | egrep -o " = ([0-9.]+)" | cut -d ' ' -f 3)"
	
	case "${condition}" in
	"check")
		# All good
		code=0
		string+="${current} is OK(${condition}) "
		perfdata+=" ${current}=${percent}"
		;;
	"resync")
		code=2
		string+="${current} is CRITICAL(${condition}) "
		perfdata+=" ${current}=${percent}"
		;;
	"reshape")
		code=1
		string+="${current} is WARNING(${condition}) "
		perfdata+=" ${current}=${percent}"
		;;
	*)
		# Just a spacer line, ignore	
		continue
		;;
	esac
done < /proc/mdstat

echo "${string}|${perfdata}"
exit ${code}
