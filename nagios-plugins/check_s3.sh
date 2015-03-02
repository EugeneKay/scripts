#!/bin/bash
# nagios-plugins/check_s3.sh
# EugeneKay/Scripts
#
# Nagios plugin to check S3 bucket size
#
## Usage
#
# $ check_s3 <host> <service> <bucket> [<warn>] [<crit>]
#
# The host and service variables are used for submission of the Passive check
# to nagios. Bucket should be the bare bucket name(no s3:// prefix). Warn and
# critical values are optional, and specify the size(in bytes) above which the
# respective alert should be triggered.
#
# s3cmd is required, and .s3cfg should exist in the executing user's homedir.
#

## Constants
# Adjust as needed
AWK=$(which awk)
S3CMD=$(which s3cmd)
COMMAND_FILE="/var/spool/nagios/cmd/nagios.cmd"

## Variables
# Arguments
host="${1}"
service="${2}"
bucket="${3}"
warn="${4}"
crit="${5}"

# Default to zero
if [ -z "${warn}" ]
then
        warn="0"
        crit="0"
fi

# Current timestamp
date="$(date +%s)"

# Get qty of bytes used
s3result="$(${S3CMD} du s3://${bucket})"
s3return="$?"

# Extract byte count
bytes="$(echo ${s3result} | cut -d ' ' -f 1)"

# Get a human size
size=$(echo ${bytes} | ${AWK} 'function human(x) {s="bkMGTEPYZ";while (x>=1000 &
& length(s)>1){x/=1024; s=substr(s,2)}return int(x+0.5) substr(s,1,1)}{gsub(/^[0
-9]+/, human($1)); print}')

# Figure out status
if [ "${s3return}" -ne "0" ]
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

# Submit a passive check
echo "[${date}] PROCESS_SERVICE_CHECK_RESULT;aws;S3-Backup;${code};check_s3: ${bucket} is ${status}(${size}) | ${bucket}=${bytes};${warn};${crit}" > ${COMMAND_FILE}

exit 0
