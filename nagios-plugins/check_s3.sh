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
S3CMD=$(which s3cmd)
COMMAND_FILE="/var/spool/nagios/cmd/nagios.cmd"

## Variables
# Arguments
host="${1}"
service="${2}"
bucket="${3}"
warn="${4}"
crit="${5}"

# Current timestamp
date="$(date +%s)"

# Get qty of bytes used
s3result="$(${S3CMD} du s3://${bucket})"
s3return="$?"

# Extract byte count
size="$(echo ${s3result} | cut -d ' ' -f 1)"

# Figure out status
if [ "${s3return}" -ne "0" ]
then
	code=3
	status="UNKNOWN!"
elif [ -n "${crit}" ] && [ "${crit}" -ne 0 ] && [ "${size}" -gt "${crit}" ]
then
	code=2
	status="CRITICAL!"
elif [ -n "${warn}" ] && [ "${warn}" -ne 0 ] && [ "${size}" -gt "${warn}" ]
then
	code=1
	status="WARNING!"
else
	code=0
	status="OK!"
fi

# Submit a passive check
echo "[${date}] PROCESS_SERVICE_CHECK_RESULT;aws;S3-Backup;${code};check_s3: ${bucket} ${status} | ${bucket}=${size};${warn};${crit}" > ${COMMAND_FILE}

exit 0
