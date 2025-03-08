#!/bin/sh

MODULE=tailscale
VERSION=0.0.9
TITLE="tailscale"
DESCRIPTION="tailscale"
HOME_URL=Module_tailscale.asp
ARCH_LIST="arm armng arm64 mips mipsle"
FILE_LIST="tailscale tailscaled"

# Check and include base
DIR="$( cd "$( dirname "$BASH_SOURCE[0]" )" && pwd )"

# now include build_base.sh
. $DIR/../softcenter/build_base.sh

# change to module directory
cd $DIR

# do something here
for SC_ARCH in $ARCH_LIST
do
	cp_arch_bin
	do_build_result
	rm_arch_bin
done

