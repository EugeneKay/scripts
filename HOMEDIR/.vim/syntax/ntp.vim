" Vim syntax file
" Language: Network Time Protocol configuration ntp.conf
" Maintainer: David Ne\v{c}as (Yeti) <yeti@physics.muni.cz>
" Last Change: 2003-10-01
" URL: http://trific.ath.cx/Ftp/vim/syntax/ntp.vim

" Setup {{{
" React to possibly already-defined syntax.
" For version 5.x: Clear all syntax items unconditionally
" For version 6.x: Quit when a syntax file was already loaded
if version >= 600
  if exists("b:current_syntax")
    finish
  endif
else
  syntax clear
endif

syn case match
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" }}}
" Comments {{{
syn match ntpComment "#.*$" contains=ntpTodo
syn keyword ntpTodo TODO FIXME NOT XXX contained
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" }}}
" Base constructs and sectioning {{{
syn match ntpDecNumber "\<\d\+\>"
syn match ntpDecNumber "\<\d*\.\d\+\>"
syn match ntpIP "\<\(\d\{1,3}\.\)\{3}\d\{1,3}\>"
syn match ntpLine "^" nextgroup=ntpComment,ntpKeyword skipwhite
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" }}}
" Keywords {{{
" Commands
syn keyword ntpKeyword server peer broadcast manycastclient contained
syn keyword ntpKeyword broadcastclient manycastserver multicastclient contained
syn keyword ntpKeyword autokey controlkey crypto keys keysdir contained
syn keyword ntpKeyword revoke trustedkey requestkey contained
syn keyword ntpKeyword statistics statsdir filegen contained
syn keyword ntpKeyword restrict clientlimit clientperiod contained
syn keyword ntpKeyword server fudge contained
syn keyword ntpKeyword broadcastdelay driftfile enable disable contained
syn keyword ntpKeyword logconfig logfile setvar tinker trap contained
syn keyword ntpKeyword authenticate contained
" Options
syn keyword ntpOption key autokey
syn keyword ntpOption burst iburst version prefer minpoll maxpoll ttl
syn keyword ntpOption flags privatekey publickey dhparms leap
syn keyword ntpOption loopstats peerstats clockstats rawstats
syn keyword ntpOption file type link nolink enable disable
syn keyword ntpOption time1 time2 stratum refid mode flag1 flag2 flag3 flag4
syn keyword ntpOption mask
syn keyword ntpOption auth bclient calibrate kernel monitor ntp stats
syn keyword ntpOption step panic dispersion stepout minpoll allan huffpuff
syn keyword ntpOption port interface
" Flags and others
syn keyword ntpFlag none pid day week month year age
syn keyword ntpFlag kod ignore noquery nomodify notrap lowpriotrap
syn keyword ntpFlag noserve nopeer notrust limited ntpport version
" Constants
syn keyword ntpConstant default yes no
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" }}}
" Define the default highlighting {{{
" For version 5.7 and earlier: Only when not done already
" For version 5.8 and later: Only when an item doesn't have highlighting yet
if version >= 508 || !exists("did_ntp_syntax_inits")
  if version < 508
    let did_ntp_syntax_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif

  HiLink ntpComment           Comment
  HiLink ntpTodo              Todo
  HiLink ntpKeyword           Keyword
  HiLink ntpOption            Type
  HiLink ntpFlag              Function
  HiLink ntpIP                ntpConstant
  HiLink ntpDecNumber         ntpConstant
  HiLink ntpConstant          Constant
  delcommand HiLink
endif
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" }}}
let b:current_syntax = "ntp"

