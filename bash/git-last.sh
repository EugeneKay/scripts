#!/bin/bash
#
# git-last
#
# Shows the most recent commit for each file/folder in the current directory,
# similar to GitHub's code-browser. Accepts a list of directories to be
# examined
#
# Copyright 2011 K and H Research Company (support@khresear.ch)
# License: WTFPL, any version or GNU General Public License, version 3+
#

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
	for name in ${names}
	do
		# Skip .git dirs(TODO: make this work better)
		if [ "${name}" == "./.git/" ]
		then	
			continue
		fi
		
		# Show path/filename, padded
		echo -ne ${name}":" | sed 's/\.\///g' | sed -e :a -e "s/^.\{1,${length}\}$/& /;ta"
		
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
if [ "$(git config --bool --get last.author)" == "true" ]
then
	show_auth=0
else
	show_auth=1
fi


## Runtime

# Files/directories to list info for
names=$(find $* -mindepth 1 -maxdepth 1 -type d | sort | sed 's/$/\//g' && find $* -mindepth 1 -maxdepth 1 -type f | sort)

# Minimum length of first column
length=8

# Find length of longest filename
for name in ${names}
do
	if [ ${#name} -gt $length ]
	then
		length=${#name}
	fi
done

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
		format+="%H "
	else
		format+="%h "
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

# Trim length by one to account for stripped leading ./ and trailing :
length=$(( $length - 1 ))

# Run the git_last loop and feed through paginator
git_last | less -FRSX

# Exit cleanly
exit 0
