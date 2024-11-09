#! /bin/sh
VERSION=1.5.4
ARCH_LIST="arm armng arm64 mips mipsle"

build_package(){
#cat version
#rm -f softcenter.tar.gz
#mkdir -p ./softcenter/res

#python ./gen_install.py stage1

chmod 755 ./softcenter/scripts/ks_app_install.sh
echo $VERSION > softcenter/.soft_ver
cp -rf bin_arch/$1/jq softcenter/bin/jq
cp -rf bin_arch/$1/sc_auth softcenter/bin/sc_auth
tar -zcvf softcenter.tar.gz softcenter
md5value=`md5sum softcenter.tar.gz|tr " " "\n"|sed -n 1p`
cat > ./version <<EOF
$VERSION
$md5value
EOF
cat version

cat > ./config.json.js <<EOF
{
"version":"$VERSION",
"md5":"$md5value",
"tar_url":"softcenter/softcenter.tar.gz",
"home_url":"https://raw.githubusercontent.com/SWRT-dev/softcenter/master"
}
EOF
mv -f version ../../$1/softcenter/version
mv -f config.json.js ../../$1/softcenter/config.json.js
mv -f softcenter.tar.gz ../../$1/softcenter/softcenter.tar.gz
python2 ./gen_install.py stage2 $1
rm -rf softcenter/.soft_ver
rm -rf softcenter/bin/jq
rm -rf softcenter/bin/sc_auth
#cat to_remove.txt|xargs rm -f
#rm to_remove.txt
}
for arch in $ARCH_LIST
do
	build_package $arch
done
