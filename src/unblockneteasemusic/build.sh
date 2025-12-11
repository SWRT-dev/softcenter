#!/bin/sh

MODULE="unblockneteasemusic"
VERSION="1.0.0"
TITLE="解锁网易云灰色歌曲(nodejs版)"
DESCRIPTION="解锁网易云灰色歌曲"
HOME_URL="Module_unblockneteasemusic.asp"
ARCH_LIST="arm64"
FILE_LIST="node"
FILE_URL="https://github.com/UnblockNeteaseMusic/server/raw/refs/heads/enhanced"

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

if [ "$VERSION" = "" ]; then
	echo "version not found"
	exit 3
fi
rm unblockneteasemusic/bin/Music/app.js
wget ${FILE_URL}/precompiled/app.js -O unblockneteasemusic/bin/Music/app.js
rm unblockneteasemusic/bin/Music/ca.crt
rm unblockneteasemusic/bin/Music/server.crt
rm unblockneteasemusic/bin/Music/server.key
wget ${FILE_URL}/ca.crt -O unblockneteasemusic/bin/Music/ca.crt
wget ${FILE_URL}/server.crt -O unblockneteasemusic/bin/Music/server.crt
wget ${FILE_URL}/server.key -O unblockneteasemusic/bin/Music/server.key
# now include build_base.sh
. $DIR/../softcenter/build_base.sh

# change to module directory
cd $DIR

# do something here
for SC_ARCH in $ARCH_LIST
do
	#cp_arch_bin
	do_build_result
	#rm_arch_bin
done

