#!/bin/bash

# Clean installation bootstrap for development purposes only
# Usage:    ./dvp_bootstrap_install.sh [fork] [branch] [os]
# Example:  ./dvp_bootstrap_install.sh davidcp main ubuntu

# Define variables
fork=$1
branch=$2
os=$3

# Download specified installer and compiler
wget https://raw.githubusercontent.com/$fork/davidcp/$branch/install/dvp-install-$os.sh
wget https://raw.githubusercontent.com/$fork/davidcp/$branch/src/dvp_autocompile.sh

# Execute compiler and build david core package
chmod +x dvp_autocompile.sh
./dvp_autocompile.sh --david $branch no

# Execute David Control Panel installer with default dummy options for testing
bash dvp-install-$os.sh -f -y no -e admin@test.local -p P@ssw0rd -s david-$branch-$os.test.local --with-debs /tmp/davidcp-src/debs
