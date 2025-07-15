#!/bin/bash

for file in /usr/local/david/bin/*; do
	echo "$file" >> ~/david_cli_help.txt
	[ -f "$file" ] && [ -x "$file" ] && "$file" >> ~/david_cli_help.txt
done

sed -i 's\/usr/local/david/bin/\\' ~/david_cli_help.txt
