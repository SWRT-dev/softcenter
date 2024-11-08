#!/bin/sh

# Now in module working directory

cp_arch_bin(){
if [ "$SC_ARCH" = "" ]; then
	echo "SC_ARCH not found"
	exit 4
fi
if [ "$FILE_LIST" = "" ]; then
	echo "FILE_LIST not found"
	exit 4
fi
for f in $FILE_LIST
do
	mkdir -p ${MODULE}/bin
	cp -rf bin_arch/$SC_ARCH/$f ${MODULE}/bin/$f
done
}

rm_arch_bin(){
if [ "$FILE_LIST" = "" ]; then
	echo "FILE_LIST not found"
	exit 5
fi
for f in $FILE_LIST
do
	rm -rf ${MODULE}/bin/$f
done
}

do_build_result() {
if [ "$VERSION" = "" ]; then
	echo "version not found"
	exit 3
fi
if [ "$SC_ARCH" = "" ]; then
	echo "SC_ARCH not found"
	exit 3
fi

rm -f ${MODULE}.tar.gz
#清理mac os 下文件
rm -f $MODULE/.DS_Store
rm -f $MODULE/*/.DS_Store
rm -f ${MODULE}.tar.gz

# add version to the package
cat > ${MODULE}/version <<EOF
$VERSION
EOF
cat > ${MODULE}/.arch <<EOF
$SC_ARCH
EOF

tar -zcvf ${MODULE}.tar.gz $MODULE
md5value=`md5sum ${MODULE}.tar.gz|tr " " "\n"|sed -n 1p`
cat > ./version <<EOF
$VERSION
$md5value
EOF
cat version

DATE=`date +%Y-%m-%d_%H:%M:%S`
cat > ./config.json.js <<EOF
{
"version":"$VERSION",
"md5":"$md5value",
"arch":"$SC_ARCH",
"home_url":"$HOME_URL",
"title":"$TITLE",
"description":"$DESCRIPTION",
"build_date":"$DATE"
}
EOF

#update md5
rm -rf ${MODULE}/version
rm -rf ${MODULE}/.arch
mkdir -p ../../$SC_ARCH/${MODULE}
mv -f version ../../$SC_ARCH/${MODULE}/version
mv -f config.json.js ../../$SC_ARCH/${MODULE}/config.json.js
mv -f ${MODULE}.tar.gz ../../$SC_ARCH/${MODULE}/${MODULE}.tar.gz
cp -rf ${MODULE}/res/icon-${MODULE}.png ../../res/
python2 ../softcenter/gen_install.py stage2 $SC_ARCH
}
