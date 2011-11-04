# ~/.bashrc

##
## Basics
##

## Global defaults
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi

##
## Aliases & Constants
##

## Useful shortcuts

# Load default SSH identity into ssh-agent
alias ssha='ssh-add -t 20m ~/.ssh/ssh_identity'

# Purge loaded SSH identities
alias sshd='ssh-add -D'

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
COLOR_WHITE='\033[1;37m'
COLOR_LIGHTGRAY='\033[0;37m'
COLOR_GRAY='\033[1;30m'
COLOR_BLACK='\033[0;30m'
COLOR_RED='\033[0;31m'
COLOR_LIGHTRED='\033[1;31m'
COLOR_GREEN='\033[0;32m'
COLOR_LIGHTGREEN='\033[1;32m'
COLOR_BROWN='\033[0;33m'
COLOR_YELLOW='\033[1;33m'
COLOR_BLUE='\033[0;34m'
COLOR_LIGHTBLUE='\033[1;34m'
COLOR_PURPLE='\033[0;35m'
COLOR_PINK='\033[1;35m'
COLOR_CYAN='\033[0;36m'
COLOR_LIGHTCYAN='\033[1;36m'
COLOR_DEFAULT='\033[0m'

##
## Functions
##

## Get Shell Character
#
# Echo a shell character for use in the PS1 var. Detects if there is a key
# loaded in ssh-agent and the current sudo status, and adjusts accordigly.
#
# Returns: a shell character, $(normal) or #(sudo), in green(key) or red(nokey)
# 
get_shell_char () {
	## Load runtime variables
	
	# Get ssh-agent status
	ssh-add -l 2>/dev/null >/dev/null
	ssh_status=$?
	
	# Get sudo status
	sudo -n /bin/true 2>/dev/null >/dev/null
	sudo_status=$?
	
	
	## Output formatted shell char
	
	# Color the shell char
	if [ ${ssh_status} -eq 1 ]
	then
		# No key
		echo -ne ${COLOR_RED}
	else
		# Key loaded
		echo -ne ${COLOR_GREEN}
	fi
	
	# Echo a shell character
	if [ ${sudo_status} -eq 1 ]
	then
		# Sudo failed
		echo -n '$'
	else
		# Sudo active
		echo -n '#'
	fi

	# Return the prompt to normal
	echo -ne ${COLOR_DEFAULT}
	
	
	## Exit
	
	# Return cleanly
	return 0;
	
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
export PS1="[\u@\h \W]\$(get_shell_char) "


## Load local bashrc
source ~/.bashrc.local
