#!/bin/bash
#
# git-deploy
#
# git post-receive hook to check out branches to a rsync destination
#
# Copyright 2012 K and H Research Company, 2018 Markus Treinen.
# License: WTFPL, any version or GNU General Public License, version 2+
#

##
## Documentation
##

## Installation
#
# To install git-deploy, copy this file to the hooks/ directory of a repository
# as "post-receive". Note that there is NO extension!
#
# You will need to set the git config variable deploy.$FOO.uri in order for this
# script to do anything. See the 'Configuration' section for more information.
#
# In order to function properly you must have rsync and the git-core suite on
# your system. If these are in non-standard locations or not within PATH you
# should set the RSYNC and GIT vars below. Other common utilities such as mkdir,
# cp, find, rm, umask, and tar are also required, but if you don't already have
# these you should probably see a psychiatrist.
#

## Configuration
#
# Several configuration options are supported by git-deploy, only one of which
# is mandatory(deploy.$FOO.uri). These options are all set via git-config.
# Several constants(see below) may be changed in the script itself, but you
# should not need to do so on a sane system. In all of the following, $FOO is
# the name of the branch which you wish to have automagically deployed.
#
# deploy.$FOO.opts
#	Set of options to pass to rsync. git-deploy defaults to "-rt --delete",
#	which will work (r)ecursively, attempt to maintain (t)imestamps, and
#	(delete) files which do not exist in the source. You will likely want to
#	add the --exclude=foo/ option to guard agaisnt deletion of ephermeral
#	data directories used by your application. Please note that no injection
#	checking is done against this option(patches welcome).
#
# deploy.$FOO.timestamps
#	Whether or not to attempt to maintain timestamps on the work-tree which
#	is checked-out. If true git-log is used to find the last commit which
#	affected each path in the worktre, and then 'touch -m' is used to set
#	the modification time to this date.
#	
# deploy.$FOO.uri
#	rsync URI which should be deployed to for branch $FOO. This can be any
#	scheme which is known to 'rsync', including a local filesystem path, or
#	a remote host(via SSH)
#
# deploy.$FOO.subdir
#	Only rsync the specified subdirectory of the worktree for branch $FOO.
#	This is useful if you have other stuff that should not be deployed
#	and all relevant things are under this subdirectory.
#

## Usage
#
# To use git-deploy simply push into your repo and git's hook system will take
# care of the rest. Errors and information will be shown to you as the script
# works its magic. If you wish to manually deploy you can do so by piping, on
# stdin, the same data that is fed to any git pre-receive hook.
#

## Todo
#
# 1) Split out the "meat" to a git-deploy script which can be invoked via the
#	'git' binary in a non-bare repository
#
# 2) Improve documentation wording - find an English teacher to run it by or
#	something.
#

##
## Constants
##

# Path to the git binary
GIT=$(which git)

# Path to the rsync binary
RSYNC=$(which rsync)

# Temporary directory
TMP='/tmp'

# Umask
UMASK='022'

# Rsync default opts
#RSYNC_DEFAULT='-rt --delete'
RSYNC_DEFAULT='-vrtEF --delete-after --delay-updates'

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
	
	# Check branch name (skip if not a branch)
	if [ -z "${branch}" ] || [[ ! "${ref}" =~ ^refs/heads/.* ]]
	then
		#echo "Refspec ${ref} is not a branch. Skipped!"
		continue
	fi
	
	# Don't attempt to handle deleted branches
	if [[ "${new}" =~ ^0+$ ]]
	then
		# Error && skip branch
		echo "Branch ${branch} deleted. Skipped!"
		continue
	fi
	
	# Deploy destination (skip if not set)
	dest=$(git config --get "deploy.${branch}.uri")
	if [ -z "${dest}" ]
	then
		#echo "Warning: Destination not set! Deploy skipped."
		continue
	fi

	# Extract from different directory?
	subdir=$(git config --get "deploy.${branch}.subdir")
	subdir=${subdir:-"/"}
	subdir=${subdir#"/"}

	# Rsync options
	opts=$(git config --get "deploy.${branch}.opts")
	if [ -z "${opts}" ]
	then
		opts="$RSYNC_DEFAULT"

	fi


	## Attempt to update
	echo "Branch ${branch} updated. Deploying to ${dest}..."
	
	# Create directory to archive into
	mkdir "${scratch}/${branch}"
	
	# Drop into scratchdir
	cd "${scratch}/${branch}"
	
	# Set umask
	umask "${UMASK}"
	
	# Get a copy of worktree
	$GIT archive --format=tar ${new} | tar xf -
	
	# Alter modification times?
	timestamps=$(git config --bool --get "deploy.${branch}.timestamps") 
	if [ "${timestamps}" == "true" ]
	then
		# Set modification times to last-changed
		find ./ -type f -print0 | while IFS= read -r -d '' file
		do
			# Get the date of the last commit
			last=$(git log ${branch} --pretty=format:%ad --date=rfc -1 -- "${file}")
			# Set the modification time
			touch -t $(date -d "${last}" +%Y%m%d%H%M.%S) "${file}"
		done
	fi
	
	# Copy worktree to destination
	"$RSYNC" $opts "${scratch}/${branch}/${subdir}" "${dest}"
	status=$?
	
	if [ "${status}" -ne "0" ]
	then
		echo "Error: rsync exited with exit code ${status}. Deploy may not have been successful. Please review the error log above."
	else
		echo "Deploy successful!"
	fi
	echo ""
done


##
## Cleanup
##

# Remove scratch dir
rm "${scratch}" -rf

# Unset environment variables
unset GIT RSYNC TMP GIT_DIR scratch old new ref branch dest optstimestamps file last subdir
