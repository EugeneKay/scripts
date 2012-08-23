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
# css/:           6 months ago    8b529a0 Code Style improvements [Eugene E. Kas
# img/:           9 months ago    87cef7d Favicon fix [Eugene E. Kashpureff]
# js/:            6 months ago    8b529a0 Code Style improvements [Eugene E. Kas
# licenses/:      6 months ago    8b529a0 Code Style improvements [Eugene E. Kas
# CHANGELOG.txt:  6 months ago    c97cca0 v1.2.0 [Eugene E. Kashpureff Jr]
# common.php:     10 weeks ago    f7c966d Add benchmarking [Eugene E. Kashpureff
# favicon.ico:    11 months ago   190fdb3 Add favicon, care of sannse. [Eugene E
# .htaccess:      6 months ago    cd72b17 Merge 'dev' into 'vending' for 1.2.0 r
# index.php:      10 weeks ago    f7c966d Add benchmarking [Eugene E. Kashpureff
# README.txt:     6 months ago    c97cca0 v1.2.0 [Eugene E. Kashpureff Jr]
# STYLE.txt:      6 months ago    8b529a0 Code Style improvements [Eugene E. Kas
# vendlist.php:   6 months ago    11e9e82 Separate items into "normal" and "spec
# vend.php:       6 months ago    8b529a0 Code Style improvements [Eugene E. Kas
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
	for name in ${items[@]}
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
		dir_list+=(${arg})
	fi
	if [ -f "$arg" ]
	then
		file_list+=(${arg})
	fi
done

if [ ${#dir_list[@]} -gt 0 ]
then
	dirs=($(find ${dir_list[@]} -mindepth 1 -maxdepth 1 -type d | sed 's/$/\//g'))
	files=($(find ${dir_list[@]} -mindepth 1 -maxdepth 1 -type f))
fi
if [ ${#file_list[@]} -gt 0 ]
then
	files+=($(find ${files[@]} -mindepth 0 -maxdepth 0 -type f))
fi
if [ ${#files[@]} -eq 0 ]
then
	dirs=($(find . -mindepth 1 -maxdepth 1 -type d | sed 's/$/\//g'))
	files+=($(find . -mindepth 1 -maxdepth 1 -type f))
fi

# Build the list of dirs to show info for
for dir in ${dirs[@]}
do
	# Skip .git dirs(TODO: make this work better)
	if [ "${dir}" == "./.git/" ]
	then	
		continue
	fi
	dirs_unsorted+=($(echo ${dir} | sed 's/\.\///g'))
done
# Sort the dirs list
dirs_sorted=$(for i in ${dirs_unsorted[@]}; do echo $i; done | sort)

# Build the list of files
for file in ${files[@]}
do
	files_unsorted+=($(echo ${file} | sed 's/\.\///g'))
done

# Sort the files list
files_sorted=$(for i in ${files_unsorted[@]}; do echo $i; done | sort)

# Concatenate dirs & files to form items list
for item in ${dirs_sorted} ${files_sorted}
do
	items+=(${item})
done

# Minimum length of first column
length=8

# Find length of longest item
for item in ${items[@]}
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
