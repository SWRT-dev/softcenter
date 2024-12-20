#!/bin/sh


MODULE=adbyby
VERSION=1.4
TITLE="广告屏蔽大师 Plus"
DESCRIPTION="广告屏蔽大师 Plus 可以全面过滤各种横幅、弹窗、视频广告，同时阻止跟踪、隐私窃取及各种恶意网站"
HOME_URL=Module_adbyby.asp
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
	cp bin_arch/$SC_ARCH/adbyby adbyby/adbyby/adbyby
	do_build_result
	rm adbyby/adbyby/adbyby
done
