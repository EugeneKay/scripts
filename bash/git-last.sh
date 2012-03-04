#!/bin/bash
#
# git-last
#
# Shows the most recent commit for each file/folder in the current directory,
# similar to GitHub's code-browser. Accepts a list of directories to be
# examined
#

# Ensure we're in a git worktree
if [ "$(git rev-parse --is-inside-work-tree)" != "true" ]
then
	exit 1
fi

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

# Trim length by one to account for stripped leading ./ and trailing :
length=$(( $length - 1 ))

## git_last
#
# Give some information about the last commit on directories/files
#
# Returns: 0
# Outputs: Four(4) columns containing:
#	*Filename
#	*Commit date(relative)
#	*Commit hash(short)
#	*Commit subject [Commiter]
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
		echo -ne '	'
		
		# Show last commit date, padded
		echo "$(git-log -1 --pretty=tformat:'%cr%x09%h %s [%cn]' -- ${name})"
	done
	
	# Return cleanly
	return 0
}

# Run the git_last loop and feed through paginator
git_last | less -FRSX

# Exit cleanly
exit 0
