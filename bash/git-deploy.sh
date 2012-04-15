#!/bin/bash
#
# git-deploy
#
# git post-receive hook to check out branches to a rsync destination
#
# Copyright 2012 K and H Research Company.
# License: GNU General Public License, version 2+
#

##
## Documentation
##

## Installation
#
# To install git-deploy, copy this file to the hooks/ directory of a repository
# as "post-receive". Note that there is NO extension!
#
# In order to function properly you must have rsync, and the git-core suite on
# your system. If these are in non-standard locations or not within PATH you
# should set the RSYNC and GIT vars below. Other common utilities such as mkdir,
# cp, find, rm, umask, and tar are also required, but if you don't already have
# these you should probably see a psychiatrist.
#

## Configuration
#
# You will need to set the git config variable deploy.$FOO.uri in order for this
# script to do anything, where $FOO is the branch you wish to have automagically
# deployed. 
#
# deploy.$FOO.timestamps
#	Whether or not to attempt to maintain timestamps on the work-tree which
#	is checked-out. If true or undefined git-log is used to find the last
#	commit which affected each path in the worktre, and then 'touch -m' is
#	used to set the modification time to this date. Set to false to disable
#	this behaviour if it causes performance problems or you do not need it.
#	
# deploy.$FOO.uri
#	rsync URI which should be deployed to for branch $FOO. This can be any
#	scheme which is known to 'rsync', including a local filesystem path, or
#	a remote host(via SSH)
#
# deploy.$FOO.opts
#	Set of options to pass to rsync. git-deploy defaults to "-rt", which
#	will work (r)ecuresively and attempt to maintain (t)imestamps. Please
#	note that no injection checking is done against these.
#

## Usage
#
# To use git-deploy simply push into your repo and git's hook system will take
# care of the rest. Errors and information will be shown to you as the script
# works its magic. If you wish to manually deploy you can do so by piping, on
# stdin, the same data that is fed to any git pre-receive hook.
#


##
## Constants
##

# Path to the git binary
GIT=$(which git)

# Path to the rsync binary
RSYNC=$(which rsync)

# Temporary directory
TMP="/tmp"

# Repo directory
export GIT_DIR=$(pwd)

##
## Sanity checks
##

## Existence of git
if [ ! -f "${GIT}" ]
then
	# Error && exit
	echo "Error: git binary not found"
	exit 255
fi

## Existence of rsync
if [ ! -f "${RSYNC}" ]
then
	# Error && exit
	echo "Error: rsync binary not found"
	exit 255
fi

## Existence of tmpdir
if [ ! -d "${TMP}" ]
then
	# Error && exit
	echo "Error: tmp directory not found"
	exit 255
fi


##
## Runtime
##

# Create scratch dir
if mkdir "${TMP}/git-deploy.$$"
then
	scratch="${TMP}/git-deploy.$$"
else
	# Error && exit
	echo "Error: unable to create scratch dir or already exists."
	exit
fi

# Loop through stdin
while read old new ref
do
	# Find branch name
	branch=${ref#"refs/heads/"}
	
	# Check branch name
	if [ -z "${branch}" ]
	then
		echo "Refspec ${ref} is not a branch. Skipped!"
	fi
	
	# Don't attempt to handle deleted/created branches
	if [ "${new}" = "0000000000000000000000000000000000000000" ]
	then
		# Error && skip branch
		echo "Branch ${branch} deleted. Skipped!"
		continue
	fi
	if [ "${old}" = "0000000000000000000000000000000000000000" ]
	then
		# Error && skip branch
		echo "Branch ${branch} created. Skipped!"
		continue
	fi
	
	## Attempt to update
	echo "Branch ${branch} updated. Deploying..."
	
	# Deploy destination
	dest=$(git config --get "deploy.${branch}.uri")
	if [ -z "${dest}" ]
	then
		echo "Error: Destination not set! Deploy failed."
		continue
	fi
	if [ ! -d "${dest}" ]
	then
		echo "Error: Destination ${dest} does not exist! Deploy failed."
		continue
	fi
	
	# Rsync options
	opts=$(git config --get "deploy.${branch}.opts")
	if [ -z "${opts}" ]
	then
		opts="-rt"
	fi
	
	# Create directory to archive into
	mkdir "${scratch}/${branch}"
	
	# Drop into scratchdir
	cd "${scratch}/${branch}"
	
	# Set umask
	umask 007
	
	# Get a copy of worktree
	$GIT archive --format=tar ${new} | tar xf -
	
	# Alter modification times?
	timestamps=$(git config --bool --get "deploy.${branch}.timestamps") 
	if [ "${timestamps}" != "false" ]
	then
		# Set modification times to last-changed
		for path in $(find ./ ) 
		do
			# Get the date of the last commit
			last=$(git log ${branch} --pretty=format:%ad --date=rfc -1 -- ${path})
			
			# Set the modification time
			touch -t $(date -d "${last}" +%Y%m%d%H%M.%S) ${path}
		done
	fi
	
	# Copy worktree to destination
	$RSYNC $opts "${scratch}/${branch}/" "${dest}"
	status=$?
	
	if [ "${status}" -ne "0" ]
	then
		echo "Error: rsync exited with exit code ${status}. Deploy may not have been successful. Please review the error log above."
	fi
	echo ""
done


##
## Cleanup
##

# Remove scratch dir
rm ${scratch} -rf

# Unset environment variables
unset GIT RSYNC TMP GIT_DIR scratch old new ref branch dest optstimestamps path
unset last
