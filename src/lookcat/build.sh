#!/bin/sh


MODULE=lookcat
VERSION=1.2
TITLE=光猫助手
DESCRIPTION="光猫助手: 快速设置，通过路由直接访问猫后台"
HOME_URL=Module_lookcat.asp
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

