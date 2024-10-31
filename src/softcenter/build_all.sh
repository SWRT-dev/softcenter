#!/bin/bash

#CURR_PATH=$(pwd)
CURR_PATH="$( cd "$( dirname "$BASH_SOURCE[0]" )" && pwd )"
SOFT_PATH=$(dirname $CURR_PATH)
cd ${SOFT_PATH}

modules=$(find . -maxdepth 1 -type d | grep -iv "\.\/\."|sed 's/.\///g'|sed '/\./d')
for module in ${modules}; do
	echo build module: ${module}
	
	if [ "${module}" = "softcenter" ];then
		cd ${SOFT_PATH}/${module}

		echo "build ${module}"
		sh build.sh
		continue
	elif [ "${module}" = "syncthing" ] || [ "${module}" = "lucky" ];then
		echo "skip ${module}"
		continue
	fi
	
	if [ -f ${SOFT_PATH}/${module}/build.sh ];then
		cd ${SOFT_PATH}/${module}

		echo "build ${module}"
		sh build.sh
	elif [ -f ${SOFT_PATH}/${module}/build.py ];then
		cd ${SOFT_PATH}/${module}

		echo "build ${module}"
		python build.py
	else
		echo "${module}: this module do not have build.sh script!"
	fi
done
