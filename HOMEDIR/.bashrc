# .bashrc
# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi
# Load Custom shtuff
export PATH=$PATH:$HOME/bin:/sbin:/usr/sbin
unset MAILCHECK


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
alias sdnetc='sudo dnetc -ini /etc/dnetc/dnetc.ini'
alias veb='vim ~/.export/always/.bashrc'
alias smdadm='sudo mdadm'
alias sinit='sudo init'
alias alogs='tail -f /var/log/httpd/*.log'
alias o.O='echo O.o'
alias cdc='cd && clear'
alias stail='sudo tail -f'
alias schkconfig='sudo chkconfig'
alias sexportfs='sudo exportfs'

source ~/.bashrc.local
