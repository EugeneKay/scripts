#!/bin/bash
##
## Syncup
##
#
# Syncup is a script to create incremental backups of several Remote systems
# using rsync and hardlinks. 
#
# Copyright 2011 Eugene E. Kashpureff (eugene@kashpureff.org)
# License: WTFPL, any version or GNU General Public License, version 3+
#

##
## Environment Setup
##

## Runtime vars
# Working directory. Backups are kept here.
BASEDIR="/data/backups"
# Concurrency lock-prevention dir
LOCKDIR="${BASEDIR}/.lock"
# File containing remote names
REMOTES="${BASEDIR}/.remotes"
# Number of incremental backups to keep
INCREMENTALS="45"
# Backup frequency(used as a naming string only)
FREQUENCY="daily"
# Parent backup's FREQUENCY string
PARENT="hourly"

## Env vars


##
## Script Lock
##

# Attempt to acquire lock
if mkdir "${LOCKDIR}"
then
	echo $$ > "${LOCKDIR}/pid"
else
	echo "Error: Unable to acquire script lock"
	exit
fi

# Remove lock on exit, even if abnormal
trap "rm -rf ${LOCKDIR}; exit" INT TERM EXIT

##
## Remote Syncing
##

# Loop through each defined Remote
while read remote
do
	# Extra space for readability
	echo ""
	echo "Remote: ${remote}"
	# Directory to save backups into
	backdir="${BASEDIR}/${remote}"
	# Base name for backups
	backbase="${backdir}/${FREQUENCY}"
	# Base name to copy from
	parentbase="${backdir}/${PARENT}"
	
	# Check for $backdir, create if needed
	if [ ! -d "${backdir}" ]
	then
		echo "Error: Invalid remote."
	fi
	# Check for upstream #0, fail if it's not there
	if [ ! -d "${parentbase}.0" ]
	then
		echo "Error: Parent #0 is missing."
		# Abort this Remote
		continue
	fi
	
	# Rotate backups only if parent #0 is complete(skip otherwise)
	if [ -f ${parentbase}.0/.timestamp ]
	then
		# Remove oldest backup
		if [ -d "${backbase}.${INCREMENTALS}" ]
		then
			rm -rf "${backbase}.${INCREMENTALS}"
			
			# Check that backup was actually removed
			if [ -d "${backbase}.${INCREMENTALS}" ]
			then
				echo "Error: Oldest backup was not removed!?"
				continue
			fi
		fi
		
		# Move all old backups up by one
		i=${INCREMENTALS}
		while [ $i -gt 0 ]
		do
			if [ -d "${backbase}.$[$i-1]" ]
			then	
				mv "${backbase}.$[i-1]" "${backbase}.${i}"
			fi
			i=$[$i-1]
		done
		unset i
		
		# Hard-link a new #0 from uparent #0
		cp -al "${parentbase}.0" "${backbase}.0"
	fi
done < ${REMOTES}
unset remote backdir

##
## Cleanup
##

# Get rid of variables
unset BASEDIR LOCKDIR SOURCEDIR INCREMENTALS FREQUENCY PARENT
