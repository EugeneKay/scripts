"
" ~/.vimrc
" EugeneKay
"

"" Settings changes
" Tab keys defaults to tab character
set noexpandtab
" No linefolding
set nofoldenable
" Comments become green
highlight Comment ctermfg=green
" No cursor blinking
let &guicursor = &guicursor . ",a:blinkon0"


"" File-type detection & settings
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" BIND Zonefiles
autocmd BufRead,BufNewFile *.zone set filetype=bindzone

" Markdown
autocmd BufRead,BufNewFile *.md,*.markdown set filetype=mkd
autocmd FileType nginx setlocal softtabstop=2 expandtab

" Nginx
autocmd BufRead,BufNewFile *.nginx,*/etc/nginx/*,nginx.conf set filetype=nginx
autocmd FileType nginx setlocal softtabstop=4 expandtab

" Salt
autocmd BufRead,BufNewFile *.sls set filetype=yaml

