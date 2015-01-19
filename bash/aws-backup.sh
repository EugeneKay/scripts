#!/bin/bash
# bash/aws-backup.sh
# EugeneKay/scripts
#
# Backup directories to AWS S3 via s3cmd
#

##
## Environment Setup
##

## Runtime vars
# Working directory. Staging dumps go here.
BASEDIR="/data/backups"
# Concurrency lock-prevention dir
LOCKDIR="${BASEDIR}/.lock"
# Timestamp format to use
TIMESTAMP="date +%s"
# Logfile
LOGFILE="/var/log/backups.log"
# S3cmd binary
S3CMD=$(which s3cmd)
# S3cmd vars
S3CFG="${HOME}/.s3cfg"
# Extra S3cmd options
S3OPT="--delete-removed"

# Verbosity defaults to off
VERBOSE="1"

## Arguments
while getopts ":v" opt
do
	case ${opt} in
	v)
		VERBOSE="0"
		;;
	esac
done

##
## Script Lock
##

# Attempt to acquire lock
if mkdir "${LOCKDIR}"
then
	# Save PID for inspection
	echo $$ > "${LOCKDIR}/pid"
else
	echo "Error: Unable to acquire script lock"
	if [ -f "${LOCKDIR}/pid" ]
	then
		echo "Possibly held by PID: "$(cat ${LOCKDIR}/pid)
	fi
	exit
fi

# Remove lock on exit, even if abnormal
trap "rm -rf ${LOCKDIR}; exit" INT TERM EXIT


##
## Local Dumps
##
#
# None right now. :-(
#

##
## Synchronize
##

## Relationship specifications
rel[1]="/data/local/path/of/data/ s3://bucket/remote/path/of/data"

## Perform Sync
# Loop through relationships
for relationship in "${rel[@]}"
do
	# Execute sync
	echo "Relationship: $relationship" >> ${LOGFILE}
	${S3CMD} -c ${S3CFG} sync "${S3OPT}" ${relationship} 2>&1 >> ${LOGFILE}
	echo "Done!" >> ${LOGFILE}
	echo "" >> ${LOGFILE}
done


##
## Cleanup
##

unset BASEDIR LOCKDIR TIMESTAMP S3CMD S3CFG S3OPT
unset rel
