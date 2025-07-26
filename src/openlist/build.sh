#!/bin/sh


MODULE=openlist
VERSION=1.0
TITLE="OpenList文件列表"
DESCRIPTION="一款支持多种存储的目录文件列表程序，支持 web 浏览与 webdav。"
HOME_URL=Module_openlist.asp
ARCH_LIST="arm armng arm64 mips mipsle"
FILE_LIST="openlist"

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


