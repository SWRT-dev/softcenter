#!/bin/sh

MODULE="ddnsto"
VERSION="3.0.3"
TITLE="DDNSTO远程控制"
DESCRIPTION="DDNSTO远程控制"
HOME_URL="Module_ddnsto.asp"
ARCH_LIST="arm armng arm64 mipsle"
FILE_LIST="ddnsto"

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
