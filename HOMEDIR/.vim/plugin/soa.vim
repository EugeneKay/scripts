" ~/.vim/plugins/soa.vim
"
command Soa :%s/^\t\([0-9]\{10,}\)\t\(.*\))/\="\t".strftime("%s")."\t".submatch(2).")"/ | :nohl

