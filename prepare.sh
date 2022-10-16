#!/bin/bash

PREV_DIR=$(pwd)

#Need to be in every file, where configuration used
CFG_FILE=build_config.cfg
CFG_CONTENT=$(cat $CFG_FILE | sed -r '/[^=]+=[^=]+/!d' | sed -r 's/\s+=\s/=/g')
eval "$CFG_CONTENT"

source ceho.sh

ceho colly "You have to make requirements file before installation: pip freeze | Out-File -Encoding UTF8 requirements.list" 1s

ceho greely "Starting..."

cd ./${app_name}
ceho colly "Working at buildozer.spec file..."
rm -f buildozer.spec
buildozer init

sed -i "s/title = .*/title = $app_name/" buildozer.spec
sed -i "s/package.name = .*/package.name = $package_name/" buildozer.spec
sed -i "s/package.domain = .*/package.domain = $package_domain/" buildozer.spec
sed -i "s/#android.permissions = .*/android.permissions = $android_permissions/" buildozer.spec
sed -i "s/version = .*/version = $app_version/" buildozer.spec
sed -i "s/android.arch = .*/android.arch = $app_arch/" buildozer.spec
sed -i "s/#p4a.branch = .*/p4a.branch = master/" buildozer.spec
sed -i "s/orientation = .*/orientation = $orientation/" buildozer.spec
sed -i "s/source.include_exts = .*/source.include_exts = $source_include_exts/" buildozer.spec
sed -i "s/fullscreen = .*/fullscreen = $fullscreen/" buildozer.spec
sed -i "s/# android.skip_update = .*/android.skip_update = False/" buildozer.spec
sed -i "s/osx.kivy_version = .*/osx.kivy_version = 2.2.0/" buildozer.spec
sed -i "s/osx.python_version = .*/osx.python_version = 3.8/" buildozer.spec

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
ceho colly "Modules required: $requirements_default,$requirements"

#read -p "Press any key to continue"

#ceho colly "Installing and upgrading Cython..."
#pip3 install --upgrade cython && ceho greely "Cython is good!"

#requirements_spaces=$(echo "${requirements}" | tr , ' ')

#ceho colly "Installing and upgrading requirements..."
#command="pip3 install --upgrade $requirements_spaces"
#eval $command
ceho greely "___PREPARING DONE___"

