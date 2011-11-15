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
alias ssha='ssh-add -t 20m ~/.ssh/id_rsa 2>/dev/null'

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

## PS1 Prep
#
# Prepare the shell prompt
#
# Returns: 0
#
function _ps1_prep() {
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
	
	# User @ host
	PS1=${PS1}"\u@\h "
	
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
	local index_mv=0
	local index_cp=0
	local tree_edit=0
	local tree_add=0
	local tree_del=0
	local tree_mv=0
	local tree_cp=0
	local untracked=0
	
	# Count files in index
	for filename in $(git diff --cached --name-status)
	do
		# Edited in index
		if $(echo "${filename}" | grep '^M' &>/dev/null)
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
	if [ ${index_mv} -ne 0 ]; then echo -ne " ~${index_mv}"; fi;
	if [ ${index_cp} -ne 0 ]; then echo -ne " =${index_cp}"; fi;
	
	# Work-tree counters
	echo -ne ${COLOR_YLW}
	if [ ${tree_edit} -ne 0 ]; then echo -ne " *${tree_edit}"; fi;
	if [ ${tree_add} -ne 0 ]; then echo -ne " +${tree_add}"; fi;
	if [ ${tree_del} -ne 0 ]; then echo -ne " -${tree_del}"; fi;
	if [ ${tree_mv} -ne 0 ]; then echo -ne " ~${tree_mv}"; fi;
	if [ ${tree_cp} -ne 0 ]; then echo -ne " =${tree_cp}"; fi;

	# Untracked counter
	echo -ne ${COLOR_RED}
	if [ ${untracked} -ne 0 ]; then echo -ne " !${untracked}"; fi;

	# Nnormalize color
	echo -ne ${COLOR_DEF}

	# Closing paren
	echo -ne ")"
	
	## Exit
	
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
		echo ${_ps1_pwd:0:20}"..."
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
PROMPT_COMMAND=_ps1_prep

## Load local bashrc
source ~/.bashrc.local
