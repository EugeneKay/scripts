# ~/.bashrc

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

## Useful shortcuts

# Load SSH-2 RSA identity into ssh-agent
alias ssha='ssh-add -t 60m ~/.ssh/id_rsa 2>/dev/null'

# Purge loaded SSH identities
alias sshd='ssh-add -D 2>/dev/null'

# Go home
alias cdc='cd && clear'

# Wget, ignoreing cert issues
alias wgets='wget --no-check-certificate'

# Watch Apache Logs
alias alogs='tail -f /var/log/httpd/*'


## Sudos
alias sfind='sudo find'
alias serv='sudo service'
alias svim='sudo -E vim'
alias siftop='sudo iftop -c ~/.iftoprc -i'
alias syum='sudo yum' 
alias schmod='sudo chmod'
alias schown='sudo chown'
alias schgrp='sudo chgrp'
alias sduh='sudo ~/bin/duh'
alias smount='sudo mount'
alias sumount='sudo umount'
alias smkdir='sudo mkdir'
alias smdadm='sudo mdadm'
alias sinit='sudo init'
alias stail='sudo tail -f'
alias schkconfig='sudo chkconfig'
alias sexportfs='sudo exportfs'

## Silly stuff
alias o.O='echo O.o'

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


### Prompt Related

## PS1 Build
#
# Build the shell prompt
#
# Returns: 0
#
function _ps1_build() {
	## Load runtime variables
	
	# Check if we're in a git repo
	git rev-parse --git-dir 2>/dev/null > /dev/null
	ps1_git=$?
	
	# Get ssh-agent status
	ssh-add -l 2>/dev/null >/dev/null
	ps1_ssh=$?
	
	# Get sudo status
	sudo -n /bin/true 2>/dev/null >/dev/null
	ps1_sudo=$?
	
	## Assemble the prompt
	
	# Opening bracket
	PS1="["
	
	# User @
	PS1=${PS1}"\u@"
	
	# Host info
	PS1=${PS1}"`_ps1_host` "
	
	# Current directory
	if [ ${ps1_git} -eq 0 ]
	then
		# Git info
		PS1=${PS1}"`_ps1_git`"
	else
		PS1=${PS1}"`_ps1_wd`"
	fi
	
	# Closing bracket
	PS1=${PS1}"]"
	
	# Shell character($ or #)
	PS1=${PS1}"`_ps1_sc`"
	
	# Trailing space
	PS1=${PS1}" "
	
	## Exit
	
	# Return cleanly
	return 0
	
	}
## PS1 Git Info
#
# Display some information about the git repository we're in
#
# Outputs: (branch), green if clean, red if dirty
# Returns: 0
#
_ps1_git () {
	## Load repo info
	
	# Repo directory name
	local git_name=$(basename $(git rev-parse --show-toplevel))
	
	# Current path within repo
	local git_path=$(git rev-parse --show-prefix)
	
	# Branch we're on
	local git_branch="$(git symbolic-ref HEAD 2>/dev/null)" || git_branch="(unnamed branch)"
	git_branch=${git_branch##refs/heads/}
	
	# Repo status(long form)
	local git_status=$(git status 2>/dev/null)
	
	# Reset file counters
	local index_edit=0
	local index_add=0
	local index_del=0
	local tree_edit=0
	local tree_add=0
	local tree_del=0
	local untracked=0
	
	# Count files in index
	for filename in $(git diff --cached --name-status)
	do
		# Edited in index
		if $(echo "${filename}" | grep '^M' &>/dev/null)
		then
			(( index_edit++ ))
		fi
		if $(echo "${filename}" | grep '^T' &>/dev/null)
		then
			(( index_edit++ ))
		fi
		
		# Deleted in index
		if $(echo "${filename}" | grep '^D' &>/dev/null)
		then
			(( index_del++ ))
		fi
		
		# Added in index
		if $(echo "${filename}" | grep '^A' &>/dev/null)
		then
			(( index_add++ ))
		fi
	done
	
	# Work-tree files
	for filename in $(git diff --name-status)
	do
		# Edited in tree
		if $(echo "${filename}" | grep '^M' &>/dev/null)
		then
			(( tree_edit++ ))
		fi
		
		# Deleted in tree
		if $(echo "${filename}" | grep '^D' &>/dev/null)
		then
			(( tree_del++ ))
		fi
		
		# Added in tree
		if $(echo "${filename}" | grep '^A' &>/dev/null)
		then
			(( tree_add++ ))
		fi
	done
	
	# Count untracked files
	untracked=$(git ls-files --other --exclude-standard | wc -l )
	
	## Display repo info
	
	# Repo name
	echo -ne "${git_name}"
	# In-repo path
	if [ "$git_path" != "" ]
	then
		echo -ne "/${git_path%/}"
	fi
	
	
	# Opening paren
	echo -ne " ("
	
	# Upstream status(coloration of branch name)
	local pattern="# Your branch is (ahead|behind) "
	if [[ $git_status =~ $pattern ]]
	then
		# We're at a different place than upstream
		if [[ ${BASH_REMATCH[1]} == "ahead" ]];
		then
			# Ahead
			echo -ne ${COLOR_YLW}
		else
			# Behind
			echo -ne ${COLOR_RED}
		fi
	else
		# We're at the same spot as upstream
		echo -ne ${COLOR_GRN}
	fi
	
	# Branch name
	echo -ne "${git_branch}"
	
	# Normalize color
	echo -ne ${COLOR_DEF}
	
	# Index counters
	echo -ne ${COLOR_GRN}
	if [ ${index_edit} -ne 0 ]; then echo -ne " *${index_edit}"; fi;
	if [ ${index_add} -ne 0 ]; then echo -ne " +${index_add}"; fi;
	if [ ${index_del} -ne 0 ]; then echo -ne " -${index_del}"; fi;
	
	# Work-tree counters
	echo -ne ${COLOR_YLW}
	if [ ${tree_edit} -ne 0 ]; then echo -ne " *${tree_edit}"; fi;
	if [ ${tree_add} -ne 0 ]; then echo -ne " +${tree_add}"; fi;
	if [ ${tree_del} -ne 0 ]; then echo -ne " -${tree_del}"; fi;
	if [ ${untracked} -ne 0 ]; then echo -ne " !${untracked}"; fi;
	
	# Normalize color
	echo -ne ${COLOR_DEF}
	
	# Closing paren
	echo -ne ")"
	
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
	# Get load average
	local load=$(echo "($(cut -f 1 -d ' ' < /proc/loadavg)+0.5)/1" | bc)
	
	# Determine load average
	if [ "$load" -lt 1 ]
	then
		# Light load
		echo -ne ${COLOR_GRN}
	else
		if [ "$load" -lt "$ps1_host_cores" ]
		then
			# Medium load
			echo -ne ${COLOR_YLW}
		else
			# Heavy load
			echo -ne ${COLOR_RED}
		fi
	fi
	
	# Show unqualified hostname
	echo -ne ${ps1_host_name}
	
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
	ps1_host_name=$(hostname -s)
	
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
export PATH=$PATH:$HOME/bin:/sbin:/usr/sbin

# Set default editor
export EDITOR="/usr/bin/vim"

# Don't notify about unread mail
unset MAILCHECK

## Prompt
# Prepare variables for prompt
_ps1_prep

# Set prompt
PROMPT_COMMAND=_ps1_build

## Load local bashrc
source ~/.bashrc.local
