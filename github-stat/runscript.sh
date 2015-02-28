#!/usr/bin/env bash

if [ ! $# -eq 1 ] && [ ! $# -eq 2 ]; then
	echo "Usage: $0 token [max_repo]"
	exit 1
fi

CONVERT_TO_XLSX=yes
TOKEN=$1
N=1000
if [ $# -eq 2 ]; then N=$2;	fi

# process_language lang
function process_language {
	echo
	echo "---------- LANG: $1 ------------"
	echo
	ruby script.rb $TOKEN max_repo:$N lang:$1
}

echo "Repository,Language,Par at end line,Par at begin line,Par inline,Tab indented,Space indented,Mixed indented,Spaced par,Unspaced pars,White lines,Indented lines,Lines,Bytes,Files,Download time,Extraction time,Computation time" > data.csv

process_language C
process_language Cpp
process_language PHP
process_language JavaScript
process_language C%23
process_language Python
process_language Ruby

if [ "x$CONVERT_TO_XLSX" = "xyes" ]; then
	# Export to xlsx
	unix2dos data.csv
	ssconvert data.csv data.xlsx 2>&1 >/dev/null
fi
