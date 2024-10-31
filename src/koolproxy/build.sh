#!/bin/sh


MODULE=koolproxy
VERSION=3.8.5.6
TITLE=koolproxy
DESCRIPTION=去广告，没烦恼
HOME_URL=Module_koolproxy.asp
ARCH_LIST="arm armng arm64 mips mipsle"
FILE_LIST="koolproxy"

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
	cp bin_arch/$SC_ARCH/koolproxy koolproxy/koolproxy/koolproxy
	do_build_result
	rm koolproxy/koolproxy/koolproxy
done
