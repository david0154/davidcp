#!/bin/bash

branch=${1-main}

apt -y install curl wget

curl https://raw.githubusercontent.com/davidcp/davidcp/$branch/src/dvp_autocompile.sh > /tmp/dvp_autocompile.sh
chmod +x /tmp/dvp_autocompile.sh

mkdir -p /opt/davidcp

# Building David
if bash /tmp/dvp_autocompile.sh --david --noinstall --keepbuild $branch; then
	cp /tmp/davidcp-src/deb/*.deb /opt/davidcp/
fi

# Building PHP
if bash /tmp/dvp_autocompile.sh --php --noinstall --keepbuild $branch; then
	cp /tmp/davidcp-src/deb/*.deb /opt/davidcp/
fi

# Building NGINX
if bash /tmp/dvp_autocompile.sh --nginx --noinstall --keepbuild $branch; then
	cp /tmp/davidcp-src/deb/*.deb /opt/davidcp/
fi
