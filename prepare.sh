#!/bin/bash

PREV_DIR=$(pwd)

#Need to be in every file, where configuration used
CFG_FILE=build_config.cfg
CFG_CONTENT=$(cat $CFG_FILE | sed -r '/[^=]+=[^=]+/!d' | sed -r 's/\s+=\s/=/g')
eval "$CFG_CONTENT"

source ceho.sh

cap () { tee /tmp/capture.out; }
ret () { cat /tmp/capture.out; }

clear_project=0

if [ -d ${app_name} ]; then
	while true; do
		read -p "Do you want to clear project folder? " yn
		case $yn in
			[Yy]* ) clear_project=1; break;;
			[Nn]* ) break;;
			* ) echo "Please answer yes or no.";;
		esac
	done
else
	ceho colly "!!Cloning Git of ${app_name}..."
	git clone https://github.com/alexanderkorochkin/LaboratorClient.git
fi

if [ "$clear_project" -eq 1 ]; then
	if [ -d ${app_name} ]; then
		yes | rm -r ${app_name}/
	fi
	ceho colly "Cloning Git of ${app_name}..."
	git clone https://github.com/alexanderkorochkin/LaboratorClient.git
fi

cd ${app_name}

ceho colly "NOTICE: You have to make requirements file before installation: pip freeze | Out-File -Encoding UTF8 requirements.list" 1s
ceho greely "_____STARTING PREPARE_____"

ceho colly "Working at buildozer.spec file..."
FILE=buildozer.spec
if [ -f "$FILE" ]; then
    rm -f buildozer.spec
	buildozer init
else 
    buildozer init
fi

if [ -d ~/.buildozer/android/platform/android-ndk-r21e ]; then
	export LEGACY_NDK=~/.buildozer/android/platform/android-ndk-r21e
	old_ndk=0
else
	ceho redly "Android NDK 21 hasn't been installed!"
	while true; do
		read -p "Do you wish to install Android NDK 21 for gfortran support? " yn
		case $yn in
			[Yy]* ) old_ndk=1; break;;
			[Nn]* ) old_ndk=0; break;;
			* ) echo "Please answer yes or no.";;
		esac
	done
fi

sed -i "s/title = .*/title = $app_name/" buildozer.spec
sed -i "s/package.name = .*/package.name = $package_name/" buildozer.spec
sed -i "s/package.domain = .*/package.domain = $package_domain/" buildozer.spec
sed -i "s/#android.permissions = .*/android.permissions = $android_permissions/" buildozer.spec
sed -i "s/^version = .*/version = $app_version/" buildozer.spec
sed -i "s/android.arch = .*/android.arch = $app_arch/" buildozer.spec
sed -i "s/#p4a.branch = .*/p4a.branch = master/" buildozer.spec
sed -i "s/orientation = .*/orientation = $orientation/" buildozer.spec
sed -i "s/source.include_exts = .*/source.include_exts = $source_include_exts/" buildozer.spec
sed -i "s/fullscreen = .*/fullscreen = $fullscreen/" buildozer.spec

if [ ${old_ndk} -eq 1 ]; then
    sed -i "s/#android.ndk = .*/android.ndk = 21e/" buildozer.spec
fi

ceho colly "Generating requirements from requirements.list file..."
requirements=''
isFirst=true
sed -i '1s/^\xEF\xBB\xBF//' requirements.list
while IFS= read -r line
do
  	
	if [ "${line:0:8}" != "pypiwin3" ] && [ "${line:0:7}" != "pywin32" ];
	then
		if $isFirst
		then
			IFS='='
			set $line
			requirements="${1}"
			isFirst=false
		else
			IFS='='
			set $line
			requirements="$requirements,${1}"
		fi
	fi
done < requirements.list
unset IFS

sed -i "s/^requirements = .*/requirements = $requirements_default,$requirements/" buildozer.spec
ceho greely "Modules required: $requirements_default,$requirements"
ceho greely "_____PREPARING DONE_____"

if [ ${old_ndk} -eq 0 ]; then
	cp -rlfa ../packages/. ./.buildozer/android/platform/build-arm64-v8a_armeabi-v7a
fi

source ../build.sh -run ${PREV_DIR} | cap

if [ ${old_ndk} -eq 1 ]; then
	
	cd ~/.buildozer/android/platform
	rm gcc-arm-linux-x86_64.tar.bz2
	rm gcc-arm64-linux-x86_64.tar.bz2
	wget https://github.com/mzakharo/android-gfortran/releases/download/r21e/gcc-arm-linux-x86_64.tar.bz2
	wget https://github.com/mzakharo/android-gfortran/releases/download/r21e/gcc-arm64-linux-x86_64.tar.bz2
	
	tar -jxvf gcc-arm-linux-x86_64.tar.bz2
	tar -jxvf gcc-arm64-linux-x86_64.tar.bz2
	
	cp -rlfa arm-linux-androideabi-4.9/* ~/.buildozer/android/platform/android-ndk-r21e/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64
	cp -rlfa aarch64-linux-android-4.9/* ~/.buildozer/android/platform/android-ndk-r21e/toolchains/aarch64-linux-android-4.9/prebuilt/linux-x86_64
	
	if [ -d ~/.buildozer/android/platform/android-ndk-r21e ]; then
		export LEGACY_NDK=~/.buildozer/android/platform/android-ndk-r21e
	else
		ceho redly "Android NDK 19 hasn't been installed!"
	fi
	
	cd ${PREV_DIR}/${app_name}
	
	sed -i "s/android.ndk = .*/#android.ndk = 21e/" buildozer.spec
	
	cp -rlfa ../packages/. ./.buildozer/android/platform/build-arm64-v8a_armeabi-v7a
	
	source ../build.sh -run ${PREV_DIR} | cap
fi

ceho greely "_____BUILDING COMPLETED_____"

read -p "Enter path to .apk: " apk_file
source ../adb_install.sh -run $apk_file
