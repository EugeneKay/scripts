#!/bin/bash

##
## Syncup
##

# Syncup is a script to create incremental backups of several Remote systems
# using rsync and hardlinks. 

# Copyright 2011 Eugene E. Kashpureff (eugene@kashpureff.org)
# License: GNU General Public License, version 3+

##
## Environment Setup
##

## Runtime vars
# Working directory. Backups are kept here.
BASEDIR="/data/backups"
# Concurrency lock-prevention dir
LOCKDIR="${BASEDIR}/.lock"
# Timestamp to use
TIMESTAMP=`date +%s`
# File containing remote names
REMOTES="${BASEDIR}/.remotes"
# Directory to read remote:/sources/
SOURCEDIR="${BASEDIR}/.sources"
# Number of backups to keep
BACKUPS="14"
# Backup frequency(used as a naming string only)
FREQUENCY="daily"
# Bandwidth limit, in KB/s(0 for unlimited)
BWLIMIT="250"
# Extra options for rsync
RSYNCOPTS=${1}

## Env vars


##
## Script Lock
##

# Attempt to acquire lock
if mkdir "${LOCKDIR}"
then
	echo $$ > "${LOCKDIR}/pid"
else
	echo >&2 "ERROR: Unable to acquire script lock"
fi

# Remove lock on exit, even if abnormal
trap "rm -rf ${LOCKDIR}; exit" INT TERM EXIT

##
## Remote Syncing
##

# Loop through each defined Remote
while read remote
do
	echo "Remote: ${remote}"
	# Directory to save data into
	savedir="${BASEDIR}/${remote}"
	# Base name for backups
	basename="${savedir}/${FREQUENCY}"
	# Create if it doesn't exist
	if [ ! -d "${savedir}" ]
	then
		mkdir "${savedir}"
		mkdir "${basename}.0"
	fi

	# Remove oldest backup
	if [ -d "${basename}.${BACKUPS}" ]
	then
		rm -rf "${basename}.${BACKUPS}"
	fi

	# Move all old backups up by one
	i=$[$BACKUPS-1]
	while [ $i -gt 0 ]
	do
		if [ -d "${basename}.${i}" ]
		then	
			mv "${basename}.${i}" "${basename}.$[$i+1]"
		fi
		i=$[$i-1]
	done
	unset i

	# Hard-link a new #1 from #0
	cp -al "${basename}.0" "${basename}.1"

	# Check that a list of Sources exists
	if [ -f "${SOURCEDIR}/${remote}" ]
	then
		# Loop through Sources
		while read source
		do
			echo "Source: ${source}"
			# Rsync remote:/source/ into the backup dir
			rsync -rltzR --bwlimit=${BWLIMIT} --delete-during ${source} ${basename}.0 ${RSYNCOPTS}
		done < ${SOURCEDIR}/${remote}
		unset source
	fi
	# Save timestamp
	echo "${TIMESTAMP}" > "${basename}.0/.timestamp"
	
	
	echo ""
done < ${REMOTES}
unset remote savedir

##
## Cleanup
##

unset BASEDIR LOCKDIR TIMESTAMP REMOTES SOURCEDIR BACKUPS FREQUENCY BWLIMIT RSYNCOPTS
