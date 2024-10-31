#!/bin/sh


MODULE=shellinabox
VERSION="2.5"
TITLE=shellinabox
DESCRIPTION=超强的SSH网页客户端~
HOME_URL=Module_shellinabox.asp
ARCH_LIST="arm armng arm64 mips mipsle"
FILE_LIST="shellinaboxd"

# Check and include base
DIR="$( cd "$( dirname "$BASH_SOURCE[0]" )" && pwd )"

# now include build_base.sh
. $DIR/../softcenter/build_base.sh

# change to module directory
cd $DIR

# do something here
for SC_ARCH in $ARCH_LIST
do
	cp bin_arch/$SC_ARCH/shellinaboxd shellinabox/shellinabox/shellinaboxd
	do_build_result
	rm shellinabox/shellinabox/shellinaboxd
done

