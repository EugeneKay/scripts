#!/bin/bash

# xpaste

# Copyright Sitaram Chamarty(sitaramc@gmail.com)
# Licensed under GPLv3+

# input can be:
#   - piped in
#   - found in the clipboard (primary; we don't do secondary in this)
#   - found in a filename argument

# output is a pastebin URL, as well as the URL popping up in my browser

die() { echo "$@" >&2; exit 1; }

export tmp=$(mktemp -d)
cleanup () { rm -rf $tmp; }
trap cleanup EXIT

pn=sitaram
if [[ -t 0 ]]
then
    if [[ -n $1 ]] && [[ -r "$1" ]]
    then
        cat "$1" > $tmp/paste.bin
        pn=$1
    else
        xsel > $tmp/paste.bin
    fi
else
    cat > $tmp/paste.bin
fi

pf=text
file $tmp/paste.bin | grep -q -i shell.script.text && pf=bash
file $tmp/paste.bin | grep -q -i perl.*script.text && pf=perl
file $tmp/paste.bin | grep -q -i  diff.output.text && pf=diff

# we have drivers for dpaste.com and .org.  Neither of them accept perl as a
# valid syntax (!!) but pastebin.com is now captcha hidden...

engine=dpaste.org   # DEFAULT
[ -n "$U" ] && {
    [ "$U" = "dpo" ] && engine=dpaste.org
    [ "$U" = "dpc" ] && engine=dpaste.com
}

if [ "$engine" = "dpaste.org" ]
then
    # dpaste.org
    # sends back only a 302 so you need to grab the headers and parse them
    # also, lexer and expire_options are mandatory
    curl -v                                     \
        -d lexer=text                           \
        -d expire_options=604800                \
        --data-urlencode content@$tmp/paste.bin \
    http://dpaste.org >$tmp/paste.bout 2>&1
    url="$(grep Location: $tmp/paste.bout | grep -o http.*/)"
    # (the \r at the end screws things up if you just do 'http.*'
fi


if [ "$engine" = "dpaste.com" ]
then
    # dpaste.com
    # sends back only a 302 so you need to grab the headers and parse them
    curl -v                                     \
        -d hold=on                              \
        --data-urlencode content@$tmp/paste.bin \
    http://dpaste.com >$tmp/paste.bout 2>&1
    url="$(grep Location: $tmp/paste.bout | grep -o http.*/)"
    # (the \r at the end screws things up if you just do 'http.*'
fi

# ----

echo "$url"
[ -n "$DISPLAY" ] && ff "$url"
    # can't be bothered to fix up that crappy xdg-open thingy
