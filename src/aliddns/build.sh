#!/bin/sh

MODULE="aliddns"
VERSION="2.6"
TITLE="阿里DDNS"
DESCRIPTION="aliddns"
HOME_URL="Module_aliddns.asp"
ARCH_LIST="arm armng arm64 mips mipsle"

# Check and include base
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [ "$MODULE" == "" ]; then
	echo "module not found"
	exit 1
fi

if [ -f "$DIR/$MODULE/$MODULE/install.sh" ]; then
	echo "install script not found"
	exit 2
fi

# now include build_base.sh
. $DIR/../softcenter/build_base.sh

# change to module directory
cd $DIR

# do something here
for SC_ARCH in $ARCH_LIST
do
	do_build_result
done