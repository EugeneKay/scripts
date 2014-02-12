#
# ~/.bashrc
#
# This is Eugene E. Kashpureff Jr's .bashrc. It contains a number of things
# which you may think are ugly, stupid, or downright terrifying. This is not by
# accident.
#
# Copyright 2012 Eugene E. Kashpureff (eugene@kashpureff.org)
# License: WTFPL, any version or GNU General Public License, version 3+
#


##
## Basics
##

## Global defaults
if [ -f /etc/bashrc ]
then
	. /etc/bashrc
fi

##
## Aliases & Constants
##

## Command replacements

## Useful shortcuts

# Load SSH-2 RSA identity into ssh-agent
alias ssha="ssh-add -t 60m ~/.ssh/id_rsa 2>/dev/null"

# Purge loaded SSH identities
alias sshd="ssh-add -D 2>/dev/null"

# Load SSH vars
alias sshg="source ~/.ssh/vars"

# Show loaded SSH keys
alias sshl="ssh-add -l"

# Go home
alias cdc="cd && clear"
alias cdp='cd $(pwd -P)'

# Current working dir
alias cwd="/bin/pwd -P"

# Wget, ignoreing cert issues
alias wgets="wget --no-check-certificate"

# Watch Apache Logs
alias alogs="tail -f /var/log/httpd/*"

# rtorrent launcher
alias rtorrents='true; while [ $? -eq 0 ]; do rtorrent; sleep 5; done'

# ping4 a la ping6
alias ping4="$(which ping)"
## Sudos
alias scat="sudo cat"
alias schgrp="sudo chgrp"
alias schmod="sudo chmod"
alias schown="sudo chown"
alias sduh="sudo ~/bin/duh"
alias sfind="sudo find"
alias siftop="sudo iftop -c ~/.iftoprc -i"
alias sless="sudo less"
alias smkdir="sudo mkdir"
alias smount="sudo mount"
alias stail="sudo tail -f"
alias svim="sudo -E vim"

# sbin stuff
for prog in $(ls /sbin/) $(ls /usr/sbin/)
do
        if [ ! -x /bin/${prog} ] && [ ! -x /usr/bin/${prog} ]
        then
                alias ${prog}="sudo ${prog}"
        fi
done


## Silly stuff
alias o.O="echo O.o"

## Colors
# With char escape
COLOR_BLK="\[\e[0;30m\]"
COLOR_GRY="\[\e[1;30m\]"
COLOR_WHT="\[\e[0;37m\]"
COLOR_RED="\[\e[0;31m\]"
COLOR_PNK="\[\e[1;35m\]"
COLOR_MGN="\[\e[0;35m\]"
COLOR_BLU="\[\e[0;34m\]"
COLOR_CYN="\[\e[0;36m\]"
COLOR_GRN="\[\e[0;32m\]"
COLOR_YLW="\[\e[0;33m\]"
COLOR_DEF="\[\e[0m\]"

##
## Functions
##

### Commands

## git
#
# Horrible wrapper for `git`
#
# Returns: whatever, fuck you
#
function git() {
	# Reset ps1 date var
	ps1_git_date=0

	# Path to the `git` binary
	GIT=$(which git)

	# Sanity check
	if [ ! -f ${GIT} ]
	then
		echo "Error: git binary not found" >&2
		return 255
	fi

	# Command to be executed
	command=$1

	# Remove command from $@ array
	shift 1

	# Check command against list of supported commands
	case $command in
	"cd")
		cd $(git rev-parse --show-toplevel)/${1}
		;;
	"config")
		if [ "$1" = "--global" ]
		then
			shift 1
			${GIT} config "--file=${HOME}/.gitconfig.local" "$@"
		else
			${GIT} config "$@"
		fi
		;;
	"lol")
		$GIT log --graph --all --date-order --pretty=tformat:'%x09%cr%x09%C(yellow)%h%C(green)%d%Creset %s' "$@"
		;;
	"uno")
		$GIT status --untracked=no "$@"
		;;
	"unstage")
		$GIT reset HEAD "$@"
		;;
	*)
		# Execute the git binary
		$GIT ${command} "$@"
		;;
	esac

	# Return something
	return $?

}

## ping
#
# Make ping a bit more intelligent.
#
# Returns: whatever ping does
#
function ping() {
	# Find binaries
	PING=$(which ping)
	PING6=$(which ping6)

	# Sanity checks
	if [ ! -f ${PING} ] || [ ! -f ${PING6} ] || [ ! -x ${PING} ] || [ ! -x ${PING6} ]
	then
		echo "Error: ping/6 binaries not found." >&2
		return 255
	fi

	case ${1} in
	# Explicitly 4
	"-4")
		shift 1
		${PING} "${@}"
		;;
	# Explicitly 6
	"-6")
		shift 1
		${PING6} "${@}"
		;;
	# Autodetect
	*)
		# Check for an AAAA record(IPv6)
		if [ -n "$(host -t aaaa "${1}" | grep "IPv6")" ] && [ -n "$(ip -6 address show scope global)" ]
		then
			${PING6} "${@}"
		# Fallback to IPv4
		else
			${PING} "${@}"
		fi
		;;
	esac
	# Return something
	return $?
}

### Prompt Related

## PS1 Build
#
# Build the shell prompt
#
# Returns: 0
#
function _ps1_build() {
	## Load runtime variables
	
	# Check if we're in a git worktree
	if [ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" == "true" ]
	then
		ps1_git_tree=0
		ps1_git_repo=$(git rev-parse --show-toplevel 2>/dev/null)
	else
		ps1_git_tree=1
	fi
	
	# Check if we're inside a git dir
	[ "$(git rev-parse --is-inside-git-dir 2>/dev/null)" == "true" ] && ps1_git_dir=0 || ps1_git_dir=1
	
	# Check if we need to load git repo info
	if [ ${ps1_git_tree} -eq 0 ] && [ ${ps1_git_dir} -ne 0 ] 
	then
		# Check if we've changed git repos
		if [ "${ps1_git_repo}" != "${ps1_git_repo_last}" ]
		then
			_ps1_git_load
		fi
		# Check if ps1_git data is too old
		if [ ${ps1_git_date} -le $(date +%s) ]
		then
			_ps1_git_load
		fi
	fi
		
	# Get ssh-agent status
	ssh-add -l 2>/dev/null >/dev/null
	ps1_ssh=$?
	if [ "${ps1_ssh}" -ne "0" ] && [ "${TERM}" == "screen" ] && [ -f ~/.ssh/vars ]
	then
		source ~/.ssh/vars
		ssh-add -l 2>/dev/null >/dev/null
		ps1_ssh=$?
	fi
	
	# Get sudo status
	sudo -n /bin/true 2>/dev/null >/dev/null
	ps1_sudo=$?
	
	## Assemble the prompt
	
	# Opening bracket
	PS1="["
	
	# User @
	PS1+="\u@"
	
	# Host info
	PS1+="`_ps1_host` "
	
	# Directory info
	if [ ${ps1_git_tree} -eq 0 ] && [ ${ps1_git_dir} -ne 0 ]
	then
		## Repo Info
		
		# Repo name
		PS1+=${ps1_git_repo_name}
		
		# Current path within repo
		ps1_git_repo_path=$(git rev-parse --show-prefix)
		
		# In-repo path
		if [ "${ps1_git_repo_path}" != "" ]
		then
			PS1+="/"${ps1_git_repo_path%/}
		fi
		
		# Opening paren
		PS1+=" ("
		
		# Upstream status(coloration of branch name)
		local pattern="# Your branch is (ahead|behind) "
		if [[ $git_status =~ $pattern ]]
		then
			# We're at a different place than upstream
			if [[ ${BASH_REMATCH[1]} == "ahead" ]];
			then
				# Ahead
				PS1+=${COLOR_YLW}
			else
				# Behind
				PS1+=${COLOR_RED}
			fi
		else
			# We're at the same spot as upstream
			PS1+=${COLOR_GRN}
		fi
		
		# Branch name
		PS1+=${ps1_git_branch}
		
		# Normalize color
		PS1+=${COLOR_DEF}
		
		# Index counters
		PS1+=${COLOR_GRN}
		if [ ${ps1_git_index_edit} -ne 0 ]; then PS1+=" *"${ps1_git_index_edit}; fi;
		if [ ${ps1_git_index_add} -ne 0 ]; then PS1+=" +"${ps1_git_index_add}; fi;
		if [ ${ps1_git_index_del} -ne 0 ]; then PS1+=" -"${ps1_git_index_del}; fi;
		
		# Work-tree counters
		PS1+=${COLOR_YLW}
		if [ ${ps1_git_tree_edit} -ne 0 ]; then PS1+=" *"${ps1_git_tree_edit}; fi;
		if [ ${ps1_git_tree_add} -ne 0 ]; then PS1+=" +"${ps1_git_tree_add}; fi;
		if [ ${ps1_git_tree_del} -ne 0 ]; then PS1+=" -"${ps1_git_tree_del}; fi;
		if [ ${ps1_git_untracked} -ne 0 ]; then PS1+=" !"${ps1_git_untracked}; fi;
		
		# Normalize color
		PS1+=${COLOR_DEF}
		
		# Closing paren
		PS1+=")"
	else
		# Directory info
		PS1+="`_ps1_wd`"
	fi
	
	# Closing bracket
	PS1+="]"
	
	# Shell character($ or #)
	PS1+="`_ps1_sc`"
	
	# Trailing space
	PS1+=" "
	
	## Exit
	
	# Return cleanly
	return 0
}
## PS1 Git Load
#
# Load information about the git repository we're in
#
# Returns: 0
#
_ps1_git_load () {
	## Load repo info
	
	# Repo path
	ps1_git_repo_last=${ps1_git_repo}
	
	# Repo name
	ps1_git_repo_name=$(basename ${ps1_git_repo})
	
	# Branch we're on
	ps1_git_branch="$(git symbolic-ref HEAD 2>/dev/null)" || git_branch="(unnamed branch)"
	ps1_git_branch=${ps1_git_branch##refs/heads/}
	
	# Repo status(long form)
	ps1_git_status=$(git status 2>/dev/null)
	
	# Reset file counters
	ps1_git_index_edit=0
	ps1_git_index_add=0
	ps1_git_index_del=0
	ps1_git_tree_edit=0
	ps1_git_tree_add=0
	ps1_git_tree_del=0
	ps1_git_untracked=0
	
	# Count files in index
	for filename in $(git diff --cached --name-status 2>/dev/null)
	do
		# Edited in index
		if $(echo "${filename}" | grep '^M' &>/dev/null)
		then
			(( ps1_git_index_edit++ ))
		fi
		if $(echo "${filename}" | grep '^T' &>/dev/null)
		then
			(( ps1_git_index_edit++ ))
		fi
		
		# Deleted in index
		if $(echo "${filename}" | grep '^D' &>/dev/null)
		then
			(( ps1_git_index_del++ ))
		fi
		
		# Added in index
		if $(echo "${filename}" | grep '^A' &>/dev/null)
		then
			(( ps1_git_index_add++ ))
		fi
	done
	
	# Work-tree files
	for filename in $(git diff --name-status 2>/dev/null)
	do
		# Edited in tree
		if $(echo "${filename}" | grep '^M' &>/dev/null)
		then
			(( ps1_git_tree_edit++ ))
		fi
		
		# Deleted in tree
		if $(echo "${filename}" | grep '^D' &>/dev/null)
		then
			(( ps1_git_tree_del++ ))
		fi
		
		# Added in tree
		if $(echo "${filename}" | grep '^A' &>/dev/null)
		then
			(( ps1_git_tree_add++ ))
		fi
	done
	
	# Count untracked files
	ps1_git_untracked=$(git ls-files --other --exclude-standard | wc -l )
	
	# Set the next ps1_git load for 5minutes from now
	ps1_git_date=$(($(date +%s)+300))
	
	## Exit
	
	# Return cleanly
	return 0
}

## PS1 Host Info
#
#
# Outputs: Hostname, colored by load average
# Returns: 0
#
_ps1_host () {
	## Get load averages
	read one five fifteen rest < /proc/loadavg
	local load_1=$(echo "(${one}+1.5)/1" | bc)
	local load_5=$(echo "(${five}+1.5)/1" | bc)
	local load_15=$(echo "(${fifteen}+1.5)/1" | bc)
	
	## Show load averages & hostname bits
	# 1 minute
	if [ "$load_1" -gt "$[$ps1_host_cores*2]" ]
	then
		# Extreme
		echo -ne ${COLOR_RED}
	else
		if [ "$load_1" -gt "$ps1_host_cores" ]
		then
			# Heavy
			echo -ne ${COLOR_MGN}
		else
			if [ "$load_1" -gt "1" ]
			then
				# Medium
				echo -ne ${COLOR_YLW}
			else
				# Light
				echo -ne ${COLOR_GRN}
			fi
		fi
	fi
	
	# Hostname bit
	echo -ne ${ps1_hostname_1}
	
	# 5 minutes
	if [ "$load_5" -gt "$[$ps1_host_cores*2]" ]
	then
		# Extreme
		echo -ne ${COLOR_RED}
	else
		if [ "$load_5" -gt "$ps1_host_cores" ]
		then
			# Heavy
			echo -ne ${COLOR_MGN}
		else
			if [ "$load_5" -gt "1" ]
			then
				# Medium
				echo -ne ${COLOR_YLW}
			else
				# Light
				echo -ne ${COLOR_GRN}
			fi
		fi
	fi
	
	# Hostname bit
	echo -ne ${ps1_hostname_2}
	
	# 15 minutes
	if [ "$load_15" -gt "$[$ps1_host_cores*2]" ]
	then
		# Extreme
		echo -ne ${COLOR_RED}
	else
		if [ "$load_15" -gt "$ps1_host_cores" ]
		then
			# Heavy
			echo -ne ${COLOR_MGN}
		else
			if [ "$load_15" -gt "1" ]
			then
				# Medium
				echo -ne ${COLOR_YLW}
			else
				# Light
				echo -ne ${COLOR_GRN}
			fi
		fi
	fi
	# Hostname bit
	echo -ne ${ps1_hostname_3}
	
	# Set prompt color back to normal
	echo -ne ${COLOR_DEF}
	
	# Return cleanly
	return 0;
}

## PS1 Prep
#
# Prepare variables to be used later by various PS1 functions
#
# Returns: 0
#
_ps1_prep () {
	# Core quantity(includes HyperThreading, too.... meh)
	ps1_host_cores=$(cat /proc/cpuinfo | grep processor | wc -l)
	
	# Unqualified hostname
	ps1_hostname=$(hostname -s)
	
	# Split up hostname for later usage
	ps1_hostname_1=${ps1_hostname:0:$(( ${#ps1_hostname} / 3 + ( ${#ps1_hostname} % 3 ) / 2 ))}
	ps1_hostname_2=${ps1_hostname:${#ps1_hostname_1}:$(( (${#ps1_hostname} - ${#ps1_hostname_1}) / 2 + (${#ps1_hostname} - ${#ps1_hostname_1}) % 2 ))}
	ps1_hostname_3=${ps1_hostname:$(( ${#ps1_hostname_1} + ${#ps1_hostname_2} )):$(( ${#ps1_hostname} - ${#ps1_hostname_1} - ${#ps1_hostname_2} ))}
	
	
	# Reset date of next ps1_git load to 0
	ps1_git_date=0
	
	# Reset path of ps1_git last repo
	ps1_git_repo_last=" "
	
	# Return cleanly
	return 0
}
## PS1 Working Dir
#
# 
# Outputs: working directory name, trimmed down if needed
# Returns: 0
#
_ps1_wd () {
	## Find current directory name
	_ps1_pwd=$(basename "`pwd`")
	
	## Directory name length
	if [ "${#_ps1_pwd}" -gt "25" ]
	then
		# Too long, show short version
		echo -ne ${_ps1_pwd:0:20}"..."
	else
		# Show full directory name, using PS1 special "working dir"
		echo "\W"
	fi
	
	## Exit
	
	# Return cleanly
	return 0
}

## PS1 Shell Character
#
# Echo a shell character for use in the PS1 var depending upon sudo status
#
# Outputs: a shell character, $(# if sudo), in red(green if ssh-agent has key)
# Returns: 0
# 
_ps1_sc () {
	## Output shell char
	
	# Determine color
	if [ ${ps1_ssh} -eq 0 ]
	then
		# Key loaded
		echo -ne ${COLOR_GRN}
	else
		# No key or other issue
		echo -ne ${COLOR_RED}
	fi
	
	# Echo a shell character
	if [ ${ps1_sudo} -eq 0 ]
	then
		# Sudo active
		echo -n '#'
	else
		# Sudo failed
		echo -n '$'
	fi
	
	# Return to normal color
	echo -ne ${COLOR_DEF}
	
	## Exit
	
	# Return cleanly
	return 0
}


## 
## Shell settings
##

## Variables

# Incude lots of places in PATH
export PATH=".:${HOME}/bin:/sbin:/usr/sbin:${PATH}"

# Set default editor
export EDITOR="/usr/bin/vim"

# Don't notify about unread mail
unset MAILCHECK

# Append shell history instead of overwriting
shopt -s histappend

# Store lots of history
export HISTORY=1000

## Prompt
# Prepare variables for prompt
_ps1_prep

# Set prompt
PROMPT_COMMAND=_ps1_build

## Load SSH vars
if [ "${TERM}" == "screen" ] && [ -f ~/.ssh/vars ]
then
	source ~/.ssh/vars
fi

## Load local bashrc
source ~/.bashrc.local
