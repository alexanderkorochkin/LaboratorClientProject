#!/bin/bash

PREV_DIR=$(pwd)

#Need to be in every file, where configuration used
CFG_FILE=build_config.cfg
CFG_CONTENT=$(cat $CFG_FILE | sed -r '/[^=]+=[^=]+/!d' | sed -r 's/\s+=\s/=/g')
eval "$CFG_CONTENT"

source ceho.sh

ceho colly "Pulling Git of ${app_name}..."
cd ${app_name}
git pull

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
sed -i "s/# android.skip_update = .*/android.skip_update = False/" buildozer.spec

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

source ../build.sh -run ${PREV_DIR}


