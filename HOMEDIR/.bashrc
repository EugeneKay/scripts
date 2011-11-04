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
function ps1_prep() {
	## Load runtime variables
	
	# Get ssh-agent status
	ssh-add -l 2>/dev/null >/dev/null
	ps1_ssh=$?
	
	# Get sudo status
	sudo -n /bin/true 2>/dev/null >/dev/null
	ps1_sudo=$?
	
	## Assemble the prompt
	
	# User @ host
	PS1="[\u@\h \W]"
	
	# Shell character($ or #)
	PS1=${PS1}"`ps1_sc`"
	
	# Trailing space
	PS1=${PS1}" "
	
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
ps1_sc () {
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
PROMPT_COMMAND=ps1_prep

## Load local bashrc
source ~/.bashrc.local
