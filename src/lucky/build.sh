#!/bin/sh

MODULE=lucky
VERSION=1.4.3
TITLE="lucky"
DESCRIPTION="lucky"
HOME_URL=Module_lucky.asp
ARCH_LIST="arm armng arm64 mips mipsle"
FILE_LIST="lucky"

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

