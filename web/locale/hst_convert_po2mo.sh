#!/bin/bash
if [ ! -e /usr/bin/xgettext ]; then
	echo " **********************************************************"
	echo " * Unable to find xgettext please install gettext package *"
	echo " **********************************************************"
	exit 3
fi

lang=${1-all}

if [ "$lang" == "all" ]; then
	languages=$(ls -d "$DAVID/web/locale/*/" | awk -F'/' '{print $(NF-1)}')
	for lang in $languages; do
		echo "[ * ] Update $lang "
		msgfmt "$DAVID/web/locale/$lang/LC_MESSAGES/davidcp.po" -o "$DAVID/web/locale/$lang/LC_MESSAGES/davidcp.mo"
	done
else
	echo "[ * ] Update $lang "
	msgfmt "$DAVID/web/locale/$lang/LC_MESSAGES/davidcp.po" -o "$DAVID/web/locale/$lang/LC_MESSAGES/davidcp.mo"
fi
