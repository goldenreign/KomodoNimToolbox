#!/bin/bash

project_dir=""
nim_lib_dir="$HOME/download/Nim/lib"
nimble_packages_dir="$HOME/.nimble/pkgs"
full_regen=0

lib_changed=0

if [ "$1" == "" ]
then
	echo "Usage: generate_nim_ctags_for_komodo.sh <project_dir> [full_regen(0|1)] [nim_lib_dir] [nimble_packages_dir]"
	exit 1
else
	project_dir="$1"
fi

if [ "$2" == "1" ]
then
	full_regen="$2"
fi

if [ "$3" != "" ]
then
	nim_lib_dir="$3"
fi

if [ "$4" != "" ]
then
	nimble_packages_dir="$4"
fi

rm -f "$project_dir/nimtags"

if [ ! -f "$nim_lib_dir/nimtags" -o $full_regen == "1" ]
then
	rm -f "$nim_lib_dir/nimtags"
	find "$nim_lib_dir" -wholename "$nim_lib_dir/*.nim" | xargs ctags --options=NONE --options="$HOME/.ctags_nim_komodo" -R --fields=+n -a -f "$nim_lib_dir/nimtags" 2>/dev/null
	lib_changed=1
fi

if [ ! -f "$nimble_packages_dir/nimtags" -o $full_regen == "1" -o $lib_changed -eq 1 ]
then
	rm -f "$nimble_packages_dir/nimtags"
	tail --lines=+0 "$nim_lib_dir/nimtags" >> "$nimble_packages_dir/nimtags"
	find "$nimble_packages_dir" -wholename "$nimble_packages_dir/*.nim" | xargs ctags --options=NONE --options="$HOME/.ctags_nim_komodo" -R --fields=+n -a -f "$nimble_packages_dir/nimtags" 2>/dev/null
fi
tail --lines=+0 "$nimble_packages_dir/nimtags" >> "$project_dir/nimtags"

find "$project_dir" -wholename "$project_dir/*.nim" | xargs ctags --options=NONE --options="$HOME/.ctags_nim_komodo" -R --fields=+n -a -f "$project_dir/nimtags" 2>/dev/null

# Add fake function at the end of file (workaround koctags bug)
if [ `wc -l < "$project_dir/nimtags"` -gt 7 ]
then
	echo -e "myfakefunc123\t/myfakefunc123.nim\t/^  proc myfakefunc123(a: int): int =$/;\"\tf\tline:1" >> "$project_dir/nimtags"
fi

exit 0
