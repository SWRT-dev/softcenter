#!/bin/sh

MODULE=ddnspod
VERSION=2.0
TITLE=DDnspod
DESCRIPTION=使用Dnspod的ddns服务
HOME_URL=Module_ddnspod.asp
ARCH_LIST="arm armng arm64 mips mipsle"

# Check and include base
DIR="$( cd "$( dirname "$BASH_SOURCE[0]" )" && pwd )"

# now include build_base.sh
. $DIR/../softcenter/build_base.sh

# change to module directory
cd $DIR

# do something here
for SC_ARCH in $ARCH_LIST
do
	do_build_result
done

