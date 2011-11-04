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
alias ssha='ssh-add -t 20m ~/.ssh/identity'

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
# Without escapes
COLOR_CODE_BLK="\e[0;30m"
COLOR_CODE_GRY="\e[1;30m"
COLOR_CODE_WHT="\e[0;37m"
COLOR_CODE_RED="\e[0;31m"
COLOR_CODE_PNK="\e[1;35m"
COLOR_CODE_MGN="\e[0;35m"
COLOR_CODE_BLU="\e[0;34m"
COLOR_CODE_CYN="\e[0;36m"
COLOR_CODE_GRN="\e[0;32m"
COLOR_CODE_YLW="\e[0;33m"
COLOR_CODE_DEF="\e[0m"


##
## Functions
##

## Get Shell Character
#
# Echo a shell character for use in the PS1 var depending upon sudo status
#
# Outputs: a shell character; # if sudo is available, $ otherwise
# Returns: 0
# 
get_shell_char () {
	## Load runtime variables
	
	# Get sudo status
	sudo -n /bin/true 2>/dev/null >/dev/null
	sudo_status=$?
	
	## Output shell char
	
	# Echo a shell character
	if [ ${sudo_status} -eq 1 ]
	then
		# Sudo failed
		echo -n '$'
	else
		# Sudo active
		echo -n '#'
	fi

	## Exit
	
	# Return cleanly
	return 0;
	
	}

## Get Shell Character Color
#
# Echo a color code for the shell character in PS1, depending upon ssh-agent
# key status
#
# Outputs: a color code; green if a key is loaded, red otherwise
# Returns: 0
#
get_shell_char_color() {
	## Load runtime variables 
	
	# Get ssh-agent status
	ssh-add -l 2>/dev/null >/dev/null
	ssh_status=$?

	## Output coloring for shell char
	
	# Determine color
	if [ ${ssh_status} -eq 1 ]
	then
		# No key
		echo -ne ${COLOR_CODE_RED}
	else
		# Key loaded
		echo -ne ${COLOR_CODE_GRN}
	fi
	
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
PS1="[\u@\h \W]\[\$(get_shell_char_color)\]\$(get_shell_char)${COLOR_DEF} "


## Load local bashrc
source ~/.bashrc.local
