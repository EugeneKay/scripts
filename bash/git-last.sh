#!/bin/bash
#
# git-last
#
# Shows the most recent commit for each file/folder in the current directory,
# similar to GitHub's code-browser. Accepts a list of files or directories to be
# examined.
#
# Copyright 2012 Eugene E. Kashpureff Jr (eugene@kashpureff.org)
# License: WTFPL, any version or GNU General Public License, version 3+
#

##
## Documentation
##

## Installation
#
# To install git-last, copy this file to somewhere in your PATH. It is suggested
# to use ~/bin/. If this directory does not exist, create it. If it is not in
# your PATH you will need to add it. Consult your shell's documentation for the
# exact method to accomplish this, but the following works in bash:
#
# PATH+=":~/bin"
#
# This file should be named "git-last" when installed, NOT "git-last.sh". If you
# do this wrong then git will be very angry with you and invoking 'git last'
# will not work.
#

## Usage
#
# To use git-last, simply run 'git last'. The output should look something like:
#
# [eugene@francisdrake it-vends (dev)]$ git last
# CHANGELOG.txt:  7 weeks ago     c97cca0 v1.2.0 [Eugene E. Kashpureff Jr]
# common.php:     7 weeks ago     19fd9f7 Increase rate of special items to 10% 
# css/:           7 weeks ago     8b529a0 Code Style improvements [Eugene E. Kas
# favicon.ico:    6 months ago    190fdb3 Add favicon, care of sannse. [Eugene E
# .htaccess:      7 weeks ago     cd72b17 Merge 'dev' into 'vending' for 1.2.0 r
# img/:           5 months ago    87cef7d Favicon fix [Eugene E. Kashpureff]
# index.php:      7 weeks ago     8b529a0 Code Style improvements [Eugene E. Kas
# js/:            7 weeks ago     8b529a0 Code Style improvements [Eugene E. Kas
# licenses/:      7 weeks ago     8b529a0 Code Style improvements [Eugene E. Kas
# README.txt:     7 weeks ago     c97cca0 v1.2.0 [Eugene E. Kashpureff Jr]
# STYLE.txt:      7 weeks ago     8b529a0 Code Style improvements [Eugene E. Kas
# vendlist.php:   7 weeks ago     11e9e82 Separate items into "normal" and "spec
# vend.php:       7 weeks ago     8b529a0 Code Style improvements [Eugene E. Kas
# [eugene@francisdrake it-vends (dev)]$
#
# Output is automatically paginated through less -FSRX, which is the default git
# pager. Support for non-default PAGER is not implemented due to the author's
# laziness. If you implement this for yourself please consider submitting the
# patch back.
#

## Configuration
#
# git-last supports a single configuration option, and more are planned.
#
# last.author
#	If false, this option disables display of the [Author] field in git-last
#	output. If true or undefined, the author field is shown.
#

##
## Runtime
##

## Sanity checks

# Ensure we're in a git worktree
if [ "$(git rev-parse --is-inside-work-tree)" != "true" ]
then
	exit 1
fi


## Functions

## git_last
#
# Give some information about the last commit on directories/files
#
# Returns: 0
# Outputs: git-log with the formatting set to ${format}
#
function git_last() {
	for name in ${items}
	do
		# Show path/filename, padded
		echo -ne ${name}":" | sed -e :a -e "s/^.\{1,${length}\}$/& /;ta"
		
		# Show last commit info
		echo "$(git log -1 --pretty=tformat:"${format}" -- ${name})"
	done
	
	# Return cleanly
	return 0
}


## Config Options

# Show the date?
show_date=0

# Use long date format?
long_date=1

# Show the hash?
show_hash=0

# Use long hash format?
long_hash=1

# Show the subject?
show_subj=0

# Display the author?
if [ "$(git config --bool --get last.author)" != "false" ]
then
	show_auth=0
else
	show_auth=1
fi


## Assemble variables

# Files/directories to list info for
for arg in "$@"
do
	if [ -d "$arg" ]
	then
		dirs+=(${arg})
	fi
	if [ -f "$arg" ]
	then
		files+=(${arg})
	fi
done

if [ ${#dirs[@]} -gt 0 ]
then
	names=($(find ${dirs[@]} -mindepth 1 -maxdepth 1 -type d | sed 's/$/\//g'))
	names+=($(find ${dirs[@]} -mindepth 1 -maxdepth 1 -type f))
fi
if [ ${#files[@]} -gt 0 ]
then
	names+=($(find ${files[@]} -mindepth 0 -maxdepth 0 -type f))
fi
if [ ${#names[@]} -eq 0 ]
then
	names=($(find . -mindepth 1 -maxdepth 1 -type d | sed 's/$/\//g'))
	names+=($(find . -mindepth 1 -maxdepth 1 -type f))
fi

# Build the list of items to show info for
for name in ${names[@]}
do
	# Skip .git dirs(TODO: make this work better)
	if [ "${name}" == "./.git/" ]
	then	
		continue
	fi
	items+=($(echo ${name} | sed 's/\.\///g'))
done

# Sort the items list
items=$(for i in ${items[@]}; do echo $i; done | sort)

# Minimum length of first column
length=8

# Find length of longest item
for item in ${items}
do
	if [ ${#item} -gt $length ]
	then
		# Set length of first column to item's length
		length=${#item}
	fi
done

# Add 1 to length to account for trailing :
length=$(( $length + 1 ))

# Output formatting
format="%x09"
if [ ${show_date} -eq 0 ]
then
	if [ ${long_date} -eq 0 ]
	then
		format+="%cd%x09"
	else
		format+="%cr%x09"
	fi
fi
if [ ${show_hash} -eq 0 ]
then
	if [ ${long_hash} -eq 0 ]
	then
		format+="%C(yellow)%H%Creset "
	else
		format+="%C(yellow)%h%Creset "
	fi
fi
if [ ${show_subj} -eq 0 ]
then
	format+="%s"
fi
if [ ${show_auth} -eq 0 ]
then
	format+=" [%an]"
fi

## Execute!

# Run the git_last loop and feed through paginator
git_last | less -FRSX

# Exit cleanly
exit 0
