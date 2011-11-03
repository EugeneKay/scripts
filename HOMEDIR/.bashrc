# ~/.bashrc

##
## Basics
##

## Global defaults
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi

## Variables

# Incude lots of places in PATH
export PATH=$PATH:$HOME/bin:/sbin:/usr/sbin

# Set the prompt
export PS1="[\u@\h \W]\$ "

# Set default editor
export EDITOR="/usr/bin/vim"

# Don't notify about unread mail
unset MAILCHECK


##
## Command aliases
##

## Useful shortcuts

# Load default SSH identity into ssh-agent
alias ssha='ssh-add -t 20m ~/.ssh/ssh_identity'

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


## 
## Local bashrc
##

# Load .bashrc.local
source ~/.bashrc.local
