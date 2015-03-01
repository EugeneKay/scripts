#!/bin/bash
# nagios-plugins/check_bandwidth.sh
# EugeneKay/scripts
#
# Nagios plugin to check interface bandwidth
#
## Usage
#
# $ check_bandwidth <device> <period> <warn-rx> <crit-rx> <max-rx> [<warn-tx> <crit-tx> <max-tx>]
#
# Device: network interface on which to report statistics
# Period: length of time over which to collect statistics, in seconds
# Warn / Crit / Max: Speed in Mbit/s at which to trigger alarm or limit
#

## Constants
# Adjust as needed
BC=$(which bc)

## Variables
# Arguments
interface="${1}"
period="${2}"
warn_rx="${3}"
crit_rx="${4}"
max_rx="${5}"
warn_tx="${6}"
crit_tx="${7}"
max_tx="${8}"
if [ -z "${max_tx}" ]
then
	warn_tx="${warn_rx}"
	crit_tx="${crit_rx}"
	max_tx="${max_rx}"
fi

# Location of statistics
stats="/sys/class/net/${interface}/statistics"

# Beginning count 
rx_start=$(cat ${stats}/rx_bytes)
tx_start=$(cat ${stats}/tx_bytes)

# Wait a while...
sleep ${period}

# End count
rx_end=$(cat ${stats}/rx_bytes)
tx_end=$(cat ${stats}/tx_bytes)

# Data moved
rx_bytes=$(( ${rx_end} - ${rx_start} ))
tx_bytes=$(( ${tx_end} - ${tx_start} ))

# Calculate warning levels
warn_rx_bytes=$(( ${warn_rx} * 125000 * ${period} ))
crit_rx_bytes=$(( ${crit_rx} * 125000 * ${period} ))
warn_tx_bytes=$(( ${warn_tx} * 125000 * ${period} ))
crit_tx_bytes=$(( ${crit_tx} * 125000 * ${period} ))

# Calculate Mbps
rx_rate=$(echo "scale=2; ${rx_bytes} / ${period} / 125000" | ${BC} )
tx_rate=$(echo "scale=2; ${tx_bytes} / ${period} / 125000" | ${BC} )

# Determine status
if [ ${rx_bytes} -lt 0 ] || [ ${tx_bytes} -lt 0 ]
then
	code=3
	status="UNKNOWN!"
elif [ ${rx_bytes} -gt ${crit_rx_bytes} ] || [ ${tx_bytes} -gt ${crit_tx_bytes} ]
then
	code=2
	status="CRITICAL!"
elif [ ${rx_bytes} -gt ${warn_rx_bytes} ] || [ ${tx_bytes} -gt ${warn_tx_bytes} ]
then
	code=1
	status="WARNING!"
else
	code=0
	status="OK!"
fi

# Output status & performance data
echo "check_bandwidth: ${interface} is ${status} | ${interface}_rx=${rx_rate};${warn_rx};${crit_rx};${max_rx} ${interface}_tx=${tx_rate};${warn_tx};${crit_tx};${max_tx}"

# Exit appropriately
exit ${code}
