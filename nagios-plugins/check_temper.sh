#!/bin/bash
# nagios-plugins/check_temper.sh
# EugeneKay/scripts
#
# Nagios plugin to check TEMPer device
#
## Usage
#
# $ check_temper <scale> <warn> <crit>
#
# Scale should be either f or c, for Fahrenheit and Celsius respectively. Warn
# and crit should be a max temperature above which the respective status will
# be returned.

## Variables
# Arguments
scale="${1}"
warn="${2}"
crit="${3}"

# Default to Unknown
code=3
string="UNKNOWN!"

# Get current temperature
temp=$(temper-poll -q -${scale})

if [ $(echo "${temp}>${crit}" | bc -l) == "1" ]
then
	string="CRITICAL!"
	code=2
elif [ $(echo "${temp}>${warn}" | bc -l) == "1" ]
then
	string="WARNING!"
	code=1
elif [ -n "${temp}" ]
then
	string="OK!"
	code=0
fi

echo "check_temper: ${string}(${temp}${scale}) | temp=${temp};${warn};${crit}"
exit ${code}
