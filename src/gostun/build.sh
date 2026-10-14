#!/bin/sh

MODULE="gostun"
VERSION="1.0"
TITLE="Gostun NAT检测"
DESCRIPTION="本机NAT类型检测工具，测得你路由网络的NAT类型上限"
HOME_URL="Module_gostun.asp"
ARCH_LIST="arm armng arm64 mips mipsle"
FILE_LIST="gostun"

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
	cp_arch_bin
	do_build_result
	rm_arch_bin
done

